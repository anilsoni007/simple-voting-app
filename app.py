from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
from datetime import datetime
import os
import logging
import sys

app = Flask(__name__)
app.secret_key = 'voting-app-secret'

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    handlers=[
        logging.StreamHandler(sys.stdout)
    ]
)
logger = logging.getLogger(__name__)

# Database configuration - switches between local SQLite and RDS
if os.getenv('RDS_ENDPOINT'):
    # RDS configuration
    app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://{os.getenv('RDS_USERNAME')}:{os.getenv('RDS_PASSWORD')}@{os.getenv('RDS_ENDPOINT')}/{os.getenv('RDS_DB_NAME')}"
    logger.info(f"Using RDS database: {os.getenv('RDS_ENDPOINT')}/{os.getenv('RDS_DB_NAME')}")
else:
    # Local SQLite configuration
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///voting.db'
    logger.info("Using local SQLite database: voting.db")

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Models
class Vote(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    candidate_name = db.Column(db.String(100), nullable=False)  # 'Batman' or 'Superman'
    voter_name = db.Column(db.String(100), nullable=False)      # Name of the voter
    timestamp = db.Column(db.DateTime, default=datetime.utcnow)
    session_id = db.Column(db.Integer, db.ForeignKey('voting_session.id'))

class VotingStatus(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    is_open = db.Column(db.Boolean, default=True)

class VotingSession(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    start_time = db.Column(db.DateTime, default=datetime.utcnow)
    end_time = db.Column(db.DateTime)
    is_active = db.Column(db.Boolean, default=True)
    votes = db.relationship('Vote', backref='session', lazy=True)

# Routes
@app.route('/')
def index():
    logger.info("Index page accessed")
    status = VotingStatus.query.first()
    if not status:
        status = VotingStatus(is_open=True)
        db.session.add(status)
        db.session.commit()
        logger.info("Created initial voting status")
    
    # Get current session
    current_session = VotingSession.query.filter_by(is_active=True).first()
    if not current_session and status.is_open:
        current_session = VotingSession()
        db.session.add(current_session)
        db.session.commit()
        logger.info(f"Created new voting session: {current_session.id}")
    
    # Current votes (active session only)
    current_votes = []
    winner = None
    total_votes = 0
    if current_session:
        current_votes = db.session.query(Vote.candidate_name, db.func.count(Vote.id)).filter_by(session_id=current_session.id).group_by(Vote.candidate_name).all()
        total_votes = Vote.query.filter_by(session_id=current_session.id).count()
        logger.info(f"Retrieved {len(current_votes)} candidate results for session {current_session.id} with {total_votes} total votes")
        
        # Determine winner if voting is closed
        if not status.is_open and current_votes:
            # Convert to dict for easier comparison
            vote_counts = {candidate: count for candidate, count in current_votes}
            
            # Check if Batman or Superman has more votes
            batman_votes = vote_counts.get('Batman', 0)
            superman_votes = vote_counts.get('Superman', 0)
            
            if batman_votes > superman_votes:
                winner = 'Batman'
            elif superman_votes > batman_votes:
                winner = 'Superman'
            else:
                winner = 'Tie'  # It's a tie
    
    # Past voting sessions
    past_sessions = VotingSession.query.filter_by(is_active=False).order_by(VotingSession.end_time.desc()).limit(5).all()
    past_results = []
    for session in past_sessions:
        session_votes = db.session.query(Vote.candidate_name, db.func.count(Vote.id)).filter_by(session_id=session.id).group_by(Vote.candidate_name).all()
        past_results.append({
            'session': session,
            'votes': session_votes
        })
    logger.info(f"Retrieved {len(past_results)} past voting sessions")
    
    return render_template('index.html', votes=current_votes, voting_open=status.is_open, 
                           past_results=past_results, winner=winner, total_votes=total_votes)

@app.route('/vote', methods=['POST'])
def vote():
    client_ip = request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
    logger.info(f"Vote attempt from IP: {client_ip}")
    
    status = VotingStatus.query.first()
    if not status or not status.is_open:
        logger.warning(f"Vote rejected - voting is closed (IP: {client_ip})")
        flash('Voting is closed!')
        return redirect(url_for('index'))
    
    # Get or create current session
    current_session = VotingSession.query.filter_by(is_active=True).first()
    if not current_session:
        current_session = VotingSession()
        db.session.add(current_session)
        db.session.commit()
        logger.info(f"Created new session {current_session.id} for vote")
    
    candidate = request.form.get('candidate')
    voter_name = request.form.get('voter_name')
    
    if not voter_name or not candidate:
        flash('Both voter name and candidate selection are required!', 'error')
        return redirect(url_for('index'))
    
    # Check if voter has already voted in this session
    existing_vote = Vote.query.filter_by(
        voter_name=voter_name,
        session_id=current_session.id
    ).first()
    
    if existing_vote:
        logger.warning(f"Duplicate vote attempt by {voter_name} from IP: {client_ip}")
        flash(f'Sorry {voter_name}, you have already cast your vote. You can vote in the next election.', 'error')
        return redirect(url_for('index'))
    
    # Valid new vote
    vote = Vote(candidate_name=candidate, voter_name=voter_name, session_id=current_session.id)
    db.session.add(vote)
    db.session.commit()
    logger.info(f"Vote cast for '{candidate}' by {voter_name} in session {current_session.id} from IP: {client_ip}")
    flash(f'Thank you {voter_name}! Your vote for {candidate} has been recorded!')
    
    return redirect(url_for('index'))

@app.route('/close_voting')
def close_voting():
    client_ip = request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
    logger.info(f"Voting close requested from IP: {client_ip}")
    
    status = VotingStatus.query.first()
    if status:
        status.is_open = False
        # Close current session
        current_session = VotingSession.query.filter_by(is_active=True).first()
        if current_session:
            current_session.is_active = False
            current_session.end_time = datetime.utcnow()
            total_votes = Vote.query.filter_by(session_id=current_session.id).count()
            logger.info(f"Closed voting session {current_session.id} with {total_votes} total votes")
            
            # Determine winner
            votes = db.session.query(Vote.candidate_name, db.func.count(Vote.id)).filter_by(session_id=current_session.id).group_by(Vote.candidate_name).all()
            vote_counts = {candidate: count for candidate, count in votes}
            batman_votes = vote_counts.get('Batman', 0)
            superman_votes = vote_counts.get('Superman', 0)
            
            if batman_votes > superman_votes:
                winner = 'Batman'
            elif superman_votes > batman_votes:
                winner = 'Superman'
            else:
                winner = 'Tie'
                
            # Add winner info to flash message
            flash(f'Voting has been closed! Total votes: {total_votes}. Winner: {winner}')
        else:
            flash('Voting has been closed!')
            
        db.session.commit()
        logger.info("Voting status set to closed")
    
    return redirect(url_for('index'))

@app.route('/enable_voting')
def enable_voting():
    client_ip = request.environ.get('HTTP_X_FORWARDED_FOR', request.remote_addr)
    logger.info(f"Voting enable requested from IP: {client_ip}")
    
    status = VotingStatus.query.first()
    if status:
        status.is_open = True
        db.session.commit()
        logger.info("Voting status set to open")
    
    flash('Voting has been enabled!')
    return redirect(url_for('index'))

@app.route('/health')
def health():
    try:
        # Check database connection
        from sqlalchemy import text
        db.session.execute(text('SELECT 1'))
        logger.info("Health check passed")
        return {'status': 'healthy'}, 200
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {'status': 'unhealthy', 'error': str(e)}, 500

if __name__ == '__main__':
    logger.info("Starting Voting Application")
    with app.app_context():
        db.create_all()
        logger.info("Database tables created/verified")
    
    logger.info("Application ready - listening on 0.0.0.0:5000")
    app.run(host='0.0.0.0', port=5000, debug=False)