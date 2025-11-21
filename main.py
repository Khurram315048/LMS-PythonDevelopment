from flask import Flask, render_template, request, redirect, url_for, session
from werkzeug.security import generate_password_hash, check_password_hash
from datetime import date
from utils.db import mysql
from utils.auth import login_required
from students_module.students_routes import student
from teachers_module.teachers_routes import teacher
from config import *
import os
import re
from datetime import timedelta

app = Flask(__name__, template_folder=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'templates', 'layouts'))
app.config['FEE_UPLOAD_FOLDER']=FEE_UPLOAD_FOLDER
app.config['TEMPLATES_AUTO_RELOAD']=TEMPLATES_AUTO_RELOAD
app.config['MYSQL_HOST']=MYSQL_HOST
app.config['MYSQL_USER']=MYSQL_USER
app.config['MYSQL_PASSWORD']=MYSQL_PASSWORD
app.config['MYSQL_DB']=MYSQL_DB
app.config['SECRET_KEY']=SECRET_KEY
app.config['MYSQL_CURSORCLASS']='DictCursor' 
app.permanent_session_lifetime = timedelta(minutes=7)

mysql.init_app(app)

app.register_blueprint(student)
app.register_blueprint(teacher)

EMAIL_PATTERN=r'^[a-zA-Z0-9._%+-]+@gmail\.com$'

@app.route('/main_view', methods=['GET', 'POST'])  
def main_view():
    if request.method=='POST':
        if 'student' in request.form:
            return redirect(url_for('student.student_login'))
        elif 'teacher' in request.form:
            return redirect(url_for('teacher.teacher_login'))
    return render_template('main_view.html')  

@app.route('/user_signup', methods=['GET', 'POST'])
def user_signup():
    if request.method=='POST':
        email=request.form['email']
        if not re.match(EMAIL_PATTERN, email):
            error="Please enter a valid Gmail address (example@gmail.com)."
        password=request.form['password']
        user_type=request.form.get('user_type')
        hashed_password=generate_password_hash(password)
        cursor=mysql.connection.cursor()
        cursor.execute('SELECT * FROM users WHERE email = %s', (email,))
        user=cursor.fetchone()
        if user:
            if user['role_id']==1:
                return redirect(url_for('student.student_login'))
            elif user['role_id']==2:
                return redirect(url_for('teacher.teacher_login'))
        else:
            if user_type=='student':
                role_id=1
            elif user_type=='teacher':
                role_id=2
            else:
                role_id=None
            cursor.execute(
                'INSERT INTO users (email, password, role_id) VALUES (%s, %s, %s)',
                (email, hashed_password, role_id)
            )
            mysql.connection.commit()
            user_id=cursor.lastrowid
            if user_type=='student':
                cursor.execute(
                    'INSERT INTO students (user_id, program_id, admission_date) VALUES (%s, %s, %s)',
                    (user_id, 1, date.today())
                )
                mysql.connection.commit()
                return redirect(url_for('student.student_login'))
            elif user_type == 'teacher':
                cursor.execute(
                    'INSERT INTO teachers (user_id, joining_date) VALUES (%s, %s)',
                    (user_id, date.today())
                )
                mysql.connection.commit()
                return redirect(url_for('teacher.teacher_login'))
    return render_template('user_signup.html',error=None)


@app.route('/reset_password',methods=['GET','POST'])
def reset_password():

    cursor=mysql.connection.cursor()
    if request.method=='POST':
        email=request.form['email']
        new_password=request.form['new_password']
        cursor.execute('SELECT email FROM users WHERE email=%s',(email,))
        user=cursor.fetchone()
        if not user:
            return redirect('/user_signup')
        hash_password=generate_password_hash(new_password)
        cursor.execute('UPDATE users SET password=%s WHERE email=%s',(hash_password,email))
        mysql.connection.commit()
        if session.get('user_type')=='student':
            return redirect(url_for('student.student_login'))
        else:
            return redirect(url_for('teacher.teacher_login'))
    return render_template('reset_password.html')            
    





@app.route('/logout')
def logout():
    session.clear()
    return redirect(url_for('main_view'))

if __name__ == '__main__':
    app.run(port=50001, debug=True)