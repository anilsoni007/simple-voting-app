from flask import Flask, render_template, request, redirect, url_for, flash
from flask_sqlalchemy import SQLAlchemy
import os

app = Flask(__name__)
app.secret_key = 'voting-app-secret'

# Database configuration - switches between local SQLite and RDS
if os.getenv('RDS_ENDPOINT'):
    # RDS configuration
    app.config['SQLALCHEMY_DATABASE_URI'] = f"mysql+pymysql://{os.getenv('RDS_USERNAME')}:{os.getenv('RDS_PASSWORD')}@{os.getenv('RDS_ENDPOINT')}/{os.getenv('RDS_DB_NAME')}"
else:
    # Local SQLite configuration
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///voting.db'

app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)

# Models
class Vote(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    candidate_name = db.Column(db.String(100), nullable=False)

class VotingStatus(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    is_open = db.Column(db.Boolean, default=True)

# Routes
@app.route('/')
def index():
    status = VotingStatus.query.first()
    if not status:
        status = VotingStatus(is_open=True)
        db.session.add(status)
        db.session.commit()
    
    votes = db.session.query(Vote.candidate_name, db.func.count(Vote.id)).group_by(Vote.candidate_name).all()
    return render_template('index.html', votes=votes, voting_open=status.is_open)

@app.route('/vote', methods=['POST'])
def vote():
    status = VotingStatus.query.first()
    if not status or not status.is_open:
        flash('Voting is closed!')
        return redirect(url_for('index'))
    
    candidate = request.form.get('candidate')
    if candidate:
        vote = Vote(candidate_name=candidate)
        db.session.add(vote)
        db.session.commit()
        flash(f'Vote cast for {candidate}!')
    return redirect(url_for('index'))

@app.route('/close_voting')
def close_voting():
    status = VotingStatus.query.first()
    if status:
        status.is_open = False
        db.session.commit()
    flash('Voting has been closed!')
    return redirect(url_for('index'))

@app.route('/enable_voting')
def enable_voting():
    status = VotingStatus.query.first()
    if status:
        status.is_open = True
        db.session.commit()
    flash('Voting has been enabled!')
    return redirect(url_for('index'))

if __name__ == '__main__':
    with app.app_context():
        db.create_all()
    app.run(debug=True)