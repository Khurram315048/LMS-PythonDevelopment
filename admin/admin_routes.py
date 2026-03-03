from flask import Blueprint, render_template, request, redirect, url_for, session, flash, abort, current_app
from utils.auth import login_required
from werkzeug.security import check_password_hash
from werkzeug.utils import secure_filename
import os
from datetime import datetime
import MySQLdb.cursors
from utils.db import mysql 

admin=Blueprint('admin', __name__, template_folder='admin_views')


@admin.route('/admin_login',methods=['GET','POST'])
def admin_login():
    cursor = mysql.connection.cursor()
    if request.method =='POST':
        email=request.form['email']
        password=request.form['password']
        remember = 'remember_me' in request.form

        cursor.execute('SELECT * FROM users WHERE email=%s',(email,))
        admin_details=cursor.fetchone()
        if admin_details and check_password_hash(admin_details['password'],password):
            cursor.execute('SELECT * FROM admins WHERE email=%s',(email,))
            admin_data=cursor.fetchone()
            session['user_id'] = admin_details['user_id']
            session['role'] = 'admin'
            session['admin_id'] = admin_data['admin_id']
            session.permanent = remember
            return redirect(url_for('admin.admin_dashboard'))
        else:
            return render_template('main_view.html')
    return render_template('admin_login.html')    
    

@admin.route('/admin_dashboard', methods=['GET', 'POST'])
@login_required
def admin_dashboard():
    cursor=mysql.connection.cursor()
    cursor.execute('SELECT COUNT(*) AS total_students FROM students')
    students=cursor.fetchone()['total_students']
    cursor.execute('SELECT COUNT(*) AS total_teachers FROM teachers')
    teachers=cursor.fetchone()['total_teachers']
    cursor.execute('SELECT COUNT(*) AS pending_fee FROM student_fees WHERE fee_status=%s',("due",))
    pending=cursor.fetchone()['pending_fee']
   
    return render_template('admin_dashboard.html',students_count=students,teachers_count=teachers,pending_count=pending)


@admin.route('/admin_profile', methods=['GET', 'POST'])
@login_required
def admin_profile():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    admin_id=session.get('admin_id')
    
    cursor.execute('SELECT * FROM admins WHERE admin_id=%s', (admin_id,))
    admin_data=cursor.fetchone()
    if request.method=='POST':
        return redirect(url_for('admin.admin_edit'))
    
    return render_template('admin_profile.html', admin=admin_data)


@admin.route('/admin_edit', methods=['GET', 'POST'])
@login_required
def admin_edit():
    cursor=mysql.connection.cursor(MySQLdb.cursors.DictCursor)
    id=session.get('admin_id')

    if request.method=='POST':
        email=request.form['email']
        first_name=request.form['first_name']
        last_name=request.form['last_name']
        contact=request.form['contact']

        cursor.execute('''
            UPDATE admins 
            SET email=%s, first_name=%s, last_name=%s, contact=%s 
            WHERE admin_id=%s
        ''', (email, first_name, last_name, contact, id))
        
        mysql.connection.commit()
        flash("Profile updated successfully!", "success")
        return redirect(url_for('admin.admin_profile'))

    cursor.execute('SELECT * FROM admins WHERE admin_id=%s', (id,))
    admin_data = cursor.fetchone()
    return render_template('admin_edit.html', admin=admin_data)
    
        


    