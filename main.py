from flask import Flask,render_template,request,redirect,url_for,session
from datetime import date
from utils.db import mysql
from utils.auth import login_required
from students_module.students_routes import student
from teachers_module.teachers_routes import teacher
from admin.admin_routes import admin
from werkzeug.exceptions import RequestEntityTooLarge
from config import *
from models import MainModel
import os
import re
from datetime import timedelta

app = Flask(__name__, template_folder=os.path.join(os.path.dirname(os.path.abspath(__file__)), 'templates'))
app.config['FEE_UPLOAD_FOLDER']=FEE_UPLOAD_FOLDER
app.config['TEMPLATES_AUTO_RELOAD']=TEMPLATES_AUTO_RELOAD
app.config['MYSQL_HOST']=MYSQL_HOST
app.config['MYSQL_USER']=MYSQL_USER
app.config['MYSQL_PASSWORD']=MYSQL_PASSWORD
app.config['MYSQL_DB']=MYSQL_DB
app.config['MYSQL_PORT']=3307
app.config['SECRET_KEY']=SECRET_KEY
app.config['MYSQL_CURSORCLASS']='DictCursor'
app.permanent_session_lifetime = timedelta(minutes=7)

mysql.init_app(app)

app.register_blueprint(student)
app.register_blueprint(teacher)
app.register_blueprint(admin)

app.config['MAX_CONTENT_LENGTH']=5 * 1024 * 1024

EMAIL_PATTERN=r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'


@app.route('/main_view',methods=['GET', 'POST'])
def main_view():
    if request.method=='POST':
        if 'student' in request.form:
            return redirect(url_for('student.student_login'))
        elif 'teacher' in request.form:
            return redirect(url_for('teacher.teacher_login'))
        elif 'admin' in request.form:
            return redirect(url_for('admin.admin_login'))

    return render_template('main_view.html')


@app.route('/user_signup',methods=['GET', 'POST'])
def user_signup():
    if request.method=='POST':
        email=request.form['email']
        if not re.match(EMAIL_PATTERN, email):
            error="Please enter a valid Gmail address (example@gmail.com)."
            return render_template('user_signup.html', error=error)

        password=request.form['password']
        user_type=request.form.get('user_type')

        user=MainModel.get_user_by_email(email)
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
            elif user_type=='admin':
                role_id=3
            else:
                role_id=None

            user_id=MainModel.insert_user(email,password,role_id)
            if user_type=='student':
                MainModel.insert_student(user_id)
                return redirect(url_for('student.student_login'))
            elif user_type=='teacher':
                MainModel.insert_teacher(user_id)
                return redirect(url_for('teacher.teacher_login'))

    return render_template('user_signup.html',error=None)


@app.route('/reset_password',methods=['GET','POST'])
def reset_password():
    if request.method=='POST':
        email=request.form['email']
        new_password=request.form['new_password']

        user=MainModel.get_email_from_users(email)
        if not user:
            return redirect('/user_signup')

        MainModel.update_password(email,new_password)
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