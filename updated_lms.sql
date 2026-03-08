-- MariaDB dump 10.19  Distrib 10.4.32-MariaDB, for Win64 (AMD64)
--
-- Host: localhost    Database: lms
-- ------------------------------------------------------
-- Server version	10.4.32-MariaDB

/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;
/*!40103 SET @OLD_TIME_ZONE=@@TIME_ZONE */;
/*!40103 SET TIME_ZONE='+00:00' */;
/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;

--
-- Table structure for table `admins`
--

DROP TABLE IF EXISTS `admins`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `admins` (
  `admin_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) DEFAULT NULL,
  `last_name` varchar(50) DEFAULT NULL,
  `contact` varchar(100) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`admin_id`),
  UNIQUE KEY `email` (`email`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `admins_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `admins`
--

LOCK TABLES `admins` WRITE;
/*!40000 ALTER TABLE `admins` DISABLE KEYS */;
INSERT INTO `admins` VALUES (1,8,'Muhammad','Khuraam','923047698099','saleemkhurram420@gmail.com',0);
/*!40000 ALTER TABLE `admins` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `attendance`
--

DROP TABLE IF EXISTS `attendance`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `attendance` (
  `attendance_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_course_id` int(11) NOT NULL,
  `course_schedule_id` int(11) NOT NULL,
  `attendance_date` date NOT NULL,
  `attendance_status` enum('Present','Absent') DEFAULT 'Absent',
  `student_id` int(11) DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`attendance_id`),
  KEY `student_course_id` (`student_course_id`),
  KEY `course_schedule_id` (`course_schedule_id`),
  KEY `fk_attendance_student` (`student_id`),
  CONSTRAINT `attendance_ibfk_1` FOREIGN KEY (`student_course_id`) REFERENCES `student_course` (`student_course_id`),
  CONSTRAINT `attendance_ibfk_2` FOREIGN KEY (`course_schedule_id`) REFERENCES `course_schedule` (`course_schedule_id`),
  CONSTRAINT `fk_attendance_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `attendance`
--

LOCK TABLES `attendance` WRITE;
/*!40000 ALTER TABLE `attendance` DISABLE KEYS */;
INSERT INTO `attendance` VALUES (1,2,3,'2025-12-31','Absent',3,0),(2,3,4,'2025-12-31','Absent',4,0),(3,2,3,'2026-02-04','Absent',3,0),(4,2,3,'2026-02-04','Present',3,0),(5,3,4,'2026-02-04','Present',4,0),(6,2,3,'2026-03-04','Absent',3,0),(7,3,4,'2026-03-04','Present',4,0);
/*!40000 ALTER TABLE `attendance` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `complaint_suggestion`
--

DROP TABLE IF EXISTS `complaint_suggestion`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `complaint_suggestion` (
  `complt_sugst_id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(100) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `iamge_name` varchar(255) DEFAULT NULL,
  `user_id` int(11) DEFAULT NULL,
  `is_status` varchar(50) NOT NULL DEFAULT 'Pending',
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`complt_sugst_id`),
  KEY `user_id` (`user_id`),
  CONSTRAINT `complaint_suggestion_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `complaint_suggestion`
--

LOCK TABLES `complaint_suggestion` WRITE;
/*!40000 ALTER TABLE `complaint_suggestion` DISABLE KEYS */;
INSERT INTO `complaint_suggestion` VALUES (1,'Result','check my result',NULL,3,'Solved',0),(2,'Finance_Department','Give my salary\r\n',NULL,4,'Pending',0),(3,'Exam_Department','Where is my shedule??',NULL,3,'Pending',0);
/*!40000 ALTER TABLE `complaint_suggestion` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `course_schedule`
--

DROP TABLE IF EXISTS `course_schedule`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `course_schedule` (
  `course_schedule_id` int(11) NOT NULL AUTO_INCREMENT,
  `day_of_week` enum('Monday','Tuesday','Wednesday','Thursday','Friday') DEFAULT NULL,
  `start_time` time DEFAULT NULL,
  `end_time` time DEFAULT NULL,
  `location` varchar(100) DEFAULT NULL,
  `course_id` int(11) NOT NULL,
  `section_id` int(11) DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`course_schedule_id`),
  KEY `course_id` (`course_id`),
  KEY `section_id` (`section_id`),
  CONSTRAINT `course_schedule_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  CONSTRAINT `course_schedule_ibfk_2` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `course_schedule`
--

LOCK TABLES `course_schedule` WRITE;
/*!40000 ALTER TABLE `course_schedule` DISABLE KEYS */;
INSERT INTO `course_schedule` VALUES (1,'Monday','09:00:00','11:00:00','Class Room',1,1,0),(2,'Monday','11:00:00','01:00:00','Class Room',1,2,0),(3,'Wednesday','09:00:00','11:00:00','Lab 01',1,3,0),(4,'Wednesday','11:00:00','02:00:00','Lab 02',1,4,0);
/*!40000 ALTER TABLE `course_schedule` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `courses`
--

DROP TABLE IF EXISTS `courses`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `courses` (
  `course_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_name` varchar(100) NOT NULL,
  `course_type` varchar(50) NOT NULL,
  `program_id` int(11) NOT NULL,
  `credit_hours` int(11) DEFAULT NULL,
  `no_of_lectures` int(11) DEFAULT NULL,
  `assignments_enabled` tinyint(1) DEFAULT 1,
  `quizzes_enabled` tinyint(1) DEFAULT 1,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`course_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `courses_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `courses`
--

LOCK TABLES `courses` WRITE;
/*!40000 ALTER TABLE `courses` DISABLE KEYS */;
INSERT INTO `courses` VALUES (1,'Introduction to Computing','Regular',1,3,17,1,1,0),(2,'Programming Fundamentals','Regular',1,4,19,1,1,0),(3,'IT Infrastructure','Regular',2,3,12,1,1,0),(4,'Network Administration','Regular',2,3,19,1,1,0),(5,'Introduction to AI','Regular',3,3,22,1,1,0),(6,'Machine Learning','Regular',3,4,20,1,1,0);
/*!40000 ALTER TABLE `courses` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fyp_groups`
--

DROP TABLE IF EXISTS `fyp_groups`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fyp_groups` (
  `fyp_id` int(11) NOT NULL AUTO_INCREMENT,
  `project_title` text NOT NULL,
  `description` text DEFAULT NULL,
  `teacher_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `status` text DEFAULT 'In Progress',
  `progress` int(11) DEFAULT 0,
  `last_submission` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`fyp_id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `fyp_groups_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  CONSTRAINT `fyp_groups_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fyp_groups`
--

LOCK TABLES `fyp_groups` WRITE;
/*!40000 ALTER TABLE `fyp_groups` DISABLE KEYS */;
INSERT INTO `fyp_groups` VALUES (1,'testing updation of fyp again again2','aaaabscs',1,2,'Approved',0,'uploads/students_uploads/students_fyp_proposal/SID_2_PROJECT_REPORT-osama-new.pdf','2026-01-27 06:49:29',0),(2,'Huzaifa Title pr','i am again checking the project ',1,3,'Approved',0,'uploads/students_uploads/students_fyp_proposal/SID_3_portfolio-cv.pdf','2026-01-27 08:44:04',0),(3,'Developing LMS -Python-Flask-SQL','I want to develop the LMS of my University but with python flask and sqlalchemy.',1,5,'Pending Approval',0,'uploads/students_uploads/students_fyp_proposal/SID_5_COA_CCP_sol.pdf','2026-03-05 06:19:33',0);
/*!40000 ALTER TABLE `fyp_groups` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `fyp_messages`
--

DROP TABLE IF EXISTS `fyp_messages`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `fyp_messages` (
  `message_id` int(11) NOT NULL AUTO_INCREMENT,
  `fyp_id` int(11) NOT NULL,
  `teacher_id` int(11) NOT NULL,
  `student_id` int(11) NOT NULL,
  `sender_role` enum('teacher','student') NOT NULL,
  `message` text NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`message_id`),
  KEY `fyp_id` (`fyp_id`),
  CONSTRAINT `fyp_messages_ibfk_1` FOREIGN KEY (`fyp_id`) REFERENCES `fyp_groups` (`fyp_id`) ON DELETE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `fyp_messages`
--

LOCK TABLES `fyp_messages` WRITE;
/*!40000 ALTER TABLE `fyp_messages` DISABLE KEYS */;
INSERT INTO `fyp_messages` VALUES (1,1,1,2,'teacher','hy','2026-02-24 11:21:54',0),(2,2,1,3,'teacher','hy','2026-02-24 11:22:04',0);
/*!40000 ALTER TABLE `fyp_messages` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `notifications`
--

DROP TABLE IF EXISTS `notifications`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `notifications` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `sender_id` int(11) NOT NULL,
  `sender_role` enum('student','teacher','admin') NOT NULL,
  `receiver_id` int(11) DEFAULT NULL,
  `receiver_role` enum('student','teacher','admin') NOT NULL,
  `title` varchar(255) NOT NULL,
  `description` text NOT NULL,
  `related_course_id` int(11) DEFAULT NULL,
  `status` enum('Pending','Resolved','Rejected') DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `related_course_id` (`related_course_id`),
  KEY `sender_id` (`sender_id`),
  CONSTRAINT `notifications_ibfk_1` FOREIGN KEY (`related_course_id`) REFERENCES `courses` (`course_id`) ON DELETE SET NULL,
  CONSTRAINT `notifications_ibfk_2` FOREIGN KEY (`sender_id`) REFERENCES `users` (`user_id`) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `notifications`
--

LOCK TABLES `notifications` WRITE;
/*!40000 ALTER TABLE `notifications` DISABLE KEYS */;
/*!40000 ALTER TABLE `notifications` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `programs`
--

DROP TABLE IF EXISTS `programs`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `programs` (
  `program_id` int(11) NOT NULL AUTO_INCREMENT,
  `program_name` varchar(100) NOT NULL,
  `program_coordinator` varchar(100) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`program_id`),
  UNIQUE KEY `program_name` (`program_name`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `programs`
--

LOCK TABLES `programs` WRITE;
/*!40000 ALTER TABLE `programs` DISABLE KEYS */;
INSERT INTO `programs` VALUES (1,'BS Computer Science','Zeeshan Haider',0),(2,'BS Information Technology','Ansar Muneer',0),(3,'BS Artificial Intelligence','Shakeeb Ali',0),(4,'BS Data Science','Zohair Haider',0);
/*!40000 ALTER TABLE `programs` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `sections`
--

DROP TABLE IF EXISTS `sections`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `sections` (
  `section_id` int(11) NOT NULL AUTO_INCREMENT,
  `course_id` int(11) NOT NULL,
  `section_name` varchar(50) NOT NULL,
  `program_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `assignments_enabled` tinyint(1) DEFAULT 1,
  `quizzes_enabled` tinyint(1) DEFAULT 1,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`section_id`),
  KEY `course_id` (`course_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `sections_ibfk_1` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  CONSTRAINT `sections_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`)
) ENGINE=InnoDB AUTO_INCREMENT=10 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `sections`
--

LOCK TABLES `sections` WRITE;
/*!40000 ALTER TABLE `sections` DISABLE KEYS */;
INSERT INTO `sections` VALUES (1,1,'Blue',1,5,1,1,0),(2,1,'Green',1,5,1,1,0),(3,1,'Red',1,5,1,1,0),(4,1,'Orange',1,5,0,1,0),(5,2,'Blue',1,5,1,1,0),(6,3,'Blue',2,5,1,1,0),(7,4,'Blue',2,5,1,1,0),(8,5,'Blue',3,5,1,1,0),(9,6,'Blue',4,5,1,1,0);
/*!40000 ALTER TABLE `sections` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semester`
--

DROP TABLE IF EXISTS `semester`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `semester` (
  `semester_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `year` year(4) NOT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) DEFAULT 0,
  PRIMARY KEY (`semester_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semester`
--

LOCK TABLES `semester` WRITE;
/*!40000 ALTER TABLE `semester` DISABLE KEYS */;
INSERT INTO `semester` VALUES (1,'Fall',2026,'2026-04-03','2026-06-03','2026-03-04 11:09:11',0),(2,'Spring',2026,'2026-03-04','2026-04-03','2026-03-04 11:02:43',1);
/*!40000 ALTER TABLE `semester` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `semester_freeze_students`
--

DROP TABLE IF EXISTS `semester_freeze_students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `semester_freeze_students` (
  `freeze_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `semester` int(11) NOT NULL,
  `reason` text NOT NULL,
  `status` enum('Pending','Approved','Rejected') DEFAULT 'Pending',
  `applied_date` datetime DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`freeze_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `semester_freeze_students_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `semester_freeze_students`
--

LOCK TABLES `semester_freeze_students` WRITE;
/*!40000 ALTER TABLE `semester_freeze_students` DISABLE KEYS */;
INSERT INTO `semester_freeze_students` VALUES (1,3,5,'I am checking the semester freeze routes and methods for admin','Approved','2026-03-05 13:36:02',0);
/*!40000 ALTER TABLE `semester_freeze_students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_course`
--

DROP TABLE IF EXISTS `student_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_course` (
  `student_course_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`student_course_id`),
  KEY `student_id` (`student_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `student_course_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `student_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_course`
--

LOCK TABLES `student_course` WRITE;
/*!40000 ALTER TABLE `student_course` DISABLE KEYS */;
INSERT INTO `student_course` VALUES (1,2,1,0),(2,3,1,0),(3,4,1,0),(4,5,1,0),(5,7,3,0);
/*!40000 ALTER TABLE `student_course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_fail_subjects`
--

DROP TABLE IF EXISTS `student_fail_subjects`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_fail_subjects` (
  `student_fail_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'pending',
  `create_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`student_fail_id`),
  KEY `student_id` (`student_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `student_fail_subjects_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `student_fail_subjects_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_fail_subjects`
--

LOCK TABLES `student_fail_subjects` WRITE;
/*!40000 ALTER TABLE `student_fail_subjects` DISABLE KEYS */;
/*!40000 ALTER TABLE `student_fail_subjects` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_fees`
--

DROP TABLE IF EXISTS `student_fees`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_fees` (
  `student_fees_id` int(11) NOT NULL AUTO_INCREMENT,
  `fee_amount` decimal(10,2) NOT NULL,
  `fee_status` enum('paid','due') DEFAULT 'due',
  `update_date` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `voucher_front_pic` varchar(255) DEFAULT NULL,
  `voucher_back_pic` varchar(255) DEFAULT NULL,
  `program_id` int(11) NOT NULL,
  `fee_month` varchar(20) DEFAULT NULL,
  `student_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`student_fees_id`),
  KEY `program_id` (`program_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `student_fees_ibfk_1` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`),
  CONSTRAINT `student_fees_ibfk_2` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_fees`
--

LOCK TABLES `student_fees` WRITE;
/*!40000 ALTER TABLE `student_fees` DISABLE KEYS */;
INSERT INTO `student_fees` VALUES (1,18708.00,'paid','2025-12-31 09:10:20','uploads/students_uploads/voucher_pics/student_4_front_contact.PNG','uploads/students_uploads/voucher_pics/student_4_back_prj.PNG',1,'December',4,0),(2,68102.00,'paid','2026-03-05 07:08:03','uploads/students_uploads/voucher_pics/student_2_front_dep_view.PNG','uploads/students_uploads/voucher_pics/student_2_back_students_view.PNG',1,'January',2,0),(3,18708.00,'paid','2026-03-05 07:08:31',NULL,NULL,4,'December',5,0);
/*!40000 ALTER TABLE `student_fees` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_improvement`
--

DROP TABLE IF EXISTS `student_improvement`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_improvement` (
  `improvement_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `status` varchar(50) DEFAULT 'Pending',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`improvement_id`),
  KEY `student_id` (`student_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `student_improvement_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`),
  CONSTRAINT `student_improvement_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_improvement`
--

LOCK TABLES `student_improvement` WRITE;
/*!40000 ALTER TABLE `student_improvement` DISABLE KEYS */;
INSERT INTO `student_improvement` VALUES (1,2,1,'Pending','2026-03-05 07:56:29',0),(2,3,4,'Pending','2026-03-05 07:57:05',0);
/*!40000 ALTER TABLE `student_improvement` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_result_marks`
--

DROP TABLE IF EXISTS `student_result_marks`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_result_marks` (
  `marks_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_course_id` int(11) NOT NULL,
  `student_result_id` int(11) NOT NULL,
  `total_marks` int(11) DEFAULT 0,
  `student_grade` varchar(10) NOT NULL,
  `status` varchar(50) NOT NULL,
  `student_semester` varchar(50) DEFAULT NULL,
  `sessional_marks` int(11) DEFAULT 0,
  `mid_marks` int(11) DEFAULT 0,
  `final_marks` int(11) DEFAULT 0,
  `subject_gpa` decimal(3,2) DEFAULT 0.00,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`marks_id`),
  KEY `student_course_id` (`student_course_id`),
  KEY `student_result_id` (`student_result_id`),
  CONSTRAINT `student_result_marks_ibfk_1` FOREIGN KEY (`student_course_id`) REFERENCES `student_course` (`student_course_id`),
  CONSTRAINT `student_result_marks_ibfk_2` FOREIGN KEY (`student_result_id`) REFERENCES `student_results` (`student_result_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_result_marks`
--

LOCK TABLES `student_result_marks` WRITE;
/*!40000 ALTER TABLE `student_result_marks` DISABLE KEYS */;
INSERT INTO `student_result_marks` VALUES (1,1,2,83,'B+','Pass','5',17,23,43,3.40,0),(2,1,2,83,'B+','Pass','5',19,21,43,3.40,0),(3,1,2,92,'A-','Pass','5',19,26,47,3.80,0),(4,2,3,81,'B+','Pass','5',14,23,44,3.40,0),(5,2,3,95,'A+','Pass','5',18,28,49,4.00,0),(6,4,4,84,'B+','Pass','5',18,23,43,3.40,0),(7,3,5,81,'B+','Pass','5',13,23,45,3.40,0);
/*!40000 ALTER TABLE `student_result_marks` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_results`
--

DROP TABLE IF EXISTS `student_results`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_results` (
  `student_result_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `student_semester` varchar(50) NOT NULL,
  `overall_gpa` decimal(3,2) NOT NULL CHECK (`overall_gpa` between 0.00 and 4.00),
  `result_status` enum('Pass','Fail') NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`student_result_id`),
  KEY `student_id` (`student_id`),
  CONSTRAINT `student_results_ibfk_1` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_results`
--

LOCK TABLES `student_results` WRITE;
/*!40000 ALTER TABLE `student_results` DISABLE KEYS */;
INSERT INTO `student_results` VALUES (2,2,'5',1.27,'Fail',0),(3,3,'5',3.70,'Pass',0),(4,5,'5',3.20,'Pass',0),(5,4,'5',3.10,'Pass',0);
/*!40000 ALTER TABLE `student_results` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_section`
--

DROP TABLE IF EXISTS `student_section`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_section` (
  `student_section_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `section_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`student_section_id`),
  KEY `fk_ss_student` (`student_id`),
  KEY `fk_ss_section` (`section_id`),
  CONSTRAINT `fk_ss_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`),
  CONSTRAINT `fk_ss_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=5 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_section`
--

LOCK TABLES `student_section` WRITE;
/*!40000 ALTER TABLE `student_section` DISABLE KEYS */;
INSERT INTO `student_section` VALUES (1,2,1,0),(2,3,3,0),(3,4,4,0),(4,5,2,0);
/*!40000 ALTER TABLE `student_section` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `student_submissions`
--

DROP TABLE IF EXISTS `student_submissions`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `student_submissions` (
  `submission_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) DEFAULT NULL,
  `course_id` int(11) DEFAULT NULL,
  `section_id` int(11) DEFAULT NULL,
  `file_path` varchar(255) DEFAULT NULL,
  `submission_type` enum('assignment','quiz') DEFAULT NULL,
  `upload_date` datetime DEFAULT current_timestamp(),
  `marks` int(11) DEFAULT NULL,
  `total_marks` int(11) DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`submission_id`),
  KEY `fk_sub_student` (`student_id`),
  KEY `fk_sub_course` (`course_id`),
  KEY `fk_sub_section` (`section_id`),
  CONSTRAINT `fk_sub_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`),
  CONSTRAINT `fk_sub_section` FOREIGN KEY (`section_id`) REFERENCES `sections` (`section_id`),
  CONSTRAINT `fk_sub_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`)
) ENGINE=InnoDB AUTO_INCREMENT=7 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `student_submissions`
--

LOCK TABLES `student_submissions` WRITE;
/*!40000 ALTER TABLE `student_submissions` DISABLE KEYS */;
INSERT INTO `student_submissions` VALUES (1,3,1,3,'uploads/students_uploads/students_assignments/SID3_20260204_120727_new_cover.docx','assignment','2026-02-04 12:07:27',5,5,0),(2,3,1,3,'uploads/students_uploads/students_quizes/SID3_20260204_121554_Student_Management_System_Report_Project.docx','quiz','2026-02-04 12:15:54',2,5,0),(3,2,1,1,'uploads/students_uploads/students_assignments/SID2_20260204_135331_signup_view.PNG','assignment','2026-02-04 13:53:31',4,5,0),(4,4,1,4,'uploads/students_uploads/students_assignments/SID4_20260204_135820_add_view_st.PNG','assignment','2026-02-04 13:58:20',3,5,0),(5,4,1,4,'uploads/students_uploads/students_quizes/SID4_20260204_135954_home_view.PNG','quiz','2026-02-04 13:59:54',3,5,0),(6,2,1,1,'uploads/students_uploads/students_quizes/SID2_20260204_151638_login_view.PNG','quiz','2026-02-04 15:16:38',4,5,0);
/*!40000 ALTER TABLE `student_submissions` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `students`
--

DROP TABLE IF EXISTS `students`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `students` (
  `student_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `contact` varchar(100) NOT NULL,
  `email` varchar(255) NOT NULL,
  `last_qualification` varchar(100) DEFAULT NULL,
  `program_id` int(11) NOT NULL,
  `admission_session` varchar(50) DEFAULT NULL,
  `admission_date` date DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`student_id`),
  UNIQUE KEY `user_id` (`user_id`),
  KEY `program_id` (`program_id`),
  CONSTRAINT `students_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`),
  CONSTRAINT `students_ibfk_2` FOREIGN KEY (`program_id`) REFERENCES `programs` (`program_id`)
) ENGINE=InnoDB AUTO_INCREMENT=8 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `students`
--

LOCK TABLES `students` WRITE;
/*!40000 ALTER TABLE `students` DISABLE KEYS */;
INSERT INTO `students` VALUES (2,3,'Umair','Ullah','923150484043','ullahcentral123@gmail.com','FSC-PreMedical',1,'Fall-2023','2023-10-01',0),(3,5,'Muhammad','Huzaifa','923047698099','huzaifacentral123@gmail.com','ICS',1,'Fall-2023','2025-12-31',0),(4,6,'Muhammad','Hammad','923047698098','hammadcentral123@gmail.com','FSC-PreMedical',1,'Fall-2023','2025-12-31',0),(5,7,'Mubeen','khurram','923057698092','mubeenmuzaffar123@gmail.com','ICS',3,'Fall-2026','2026-03-04',0),(6,9,'Haris','Rizwan','03047698099','hariscentral123@gmail.com','Intermediate',4,'Spring 2026','2026-03-04',1),(7,10,'Aiman','Rizwan','923047698099','aiman123@gmail.com','FSC-Engrineering',3,'Spring 2026','2026-04-03',0);
/*!40000 ALTER TABLE `students` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `summer_registration`
--

DROP TABLE IF EXISTS `summer_registration`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `summer_registration` (
  `registration_id` int(11) NOT NULL AUTO_INCREMENT,
  `student_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `summer_semesters_id` int(11) NOT NULL,
  `registration_date` timestamp NOT NULL DEFAULT current_timestamp(),
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`registration_id`),
  KEY `fk_summer_student` (`student_id`),
  KEY `fk_summer_course` (`course_id`),
  KEY `fk_summer_semester` (`summer_semesters_id`),
  CONSTRAINT `fk_summer_course` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_summer_semester` FOREIGN KEY (`summer_semesters_id`) REFERENCES `summer_semesters` (`summer_semesters_id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `fk_summer_student` FOREIGN KEY (`student_id`) REFERENCES `students` (`student_id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `summer_registration`
--

LOCK TABLES `summer_registration` WRITE;
/*!40000 ALTER TABLE `summer_registration` DISABLE KEYS */;
INSERT INTO `summer_registration` VALUES (1,2,2,1,'2026-03-05 10:23:25',0),(2,3,4,2,'2026-03-05 11:02:18',0);
/*!40000 ALTER TABLE `summer_registration` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `summer_semesters`
--

DROP TABLE IF EXISTS `summer_semesters`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `summer_semesters` (
  `summer_semesters_id` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(50) DEFAULT NULL,
  `year` year(4) DEFAULT NULL,
  `start_date` date DEFAULT NULL,
  `end_date` date DEFAULT NULL,
  `previous_semester_id` int(11) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `status` enum('Open','Closed') NOT NULL DEFAULT 'Open',
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`summer_semesters_id`),
  KEY `previous_semester_id` (`previous_semester_id`),
  CONSTRAINT `summer_semesters_ibfk_1` FOREIGN KEY (`previous_semester_id`) REFERENCES `semester` (`semester_id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `summer_semesters`
--

LOCK TABLES `summer_semesters` WRITE;
/*!40000 ALTER TABLE `summer_semesters` DISABLE KEYS */;
INSERT INTO `summer_semesters` VALUES (1,'Winter',2026,'2026-03-05','2026-03-06',1,'2026-03-05 10:22:54','Open',0),(2,'Summer',2026,'2026-04-05','2026-07-05',1,'2026-03-05 10:25:17','Open',0);
/*!40000 ALTER TABLE `summer_semesters` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `system_settings`
--

DROP TABLE IF EXISTS `system_settings`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `system_settings` (
  `setting_key` varchar(50) NOT NULL,
  `setting_value` varchar(255) DEFAULT NULL,
  `description` text DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`setting_key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `system_settings`
--

LOCK TABLES `system_settings` WRITE;
/*!40000 ALTER TABLE `system_settings` DISABLE KEYS */;
INSERT INTO `system_settings` VALUES ('current_term','1','Fall 2026',0),('is_admission_open','0','Controls if the signup/admission page is accessible',0),('is_course_reg_open','1','Controls if students can register for new courses',0),('is_summer_app_open','0','Controls if summer semester applications are enabled',0);
/*!40000 ALTER TABLE `system_settings` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teacher_course`
--

DROP TABLE IF EXISTS `teacher_course`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teacher_course` (
  `teacher_course_id` int(11) NOT NULL AUTO_INCREMENT,
  `teacher_id` int(11) NOT NULL,
  `course_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`teacher_course_id`),
  KEY `teacher_id` (`teacher_id`),
  KEY `course_id` (`course_id`),
  CONSTRAINT `teacher_course_ibfk_1` FOREIGN KEY (`teacher_id`) REFERENCES `teachers` (`teacher_id`),
  CONSTRAINT `teacher_course_ibfk_2` FOREIGN KEY (`course_id`) REFERENCES `courses` (`course_id`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teacher_course`
--

LOCK TABLES `teacher_course` WRITE;
/*!40000 ALTER TABLE `teacher_course` DISABLE KEYS */;
INSERT INTO `teacher_course` VALUES (1,1,1,0),(2,1,2,0);
/*!40000 ALTER TABLE `teacher_course` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `teachers`
--

DROP TABLE IF EXISTS `teachers`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `teachers` (
  `teacher_id` int(11) NOT NULL AUTO_INCREMENT,
  `user_id` int(11) NOT NULL,
  `first_name` varchar(50) NOT NULL,
  `last_name` varchar(50) NOT NULL,
  `email` varchar(100) NOT NULL,
  `contact_num` varchar(100) NOT NULL,
  `qualification` varchar(100) DEFAULT NULL,
  `joining_date` date DEFAULT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`teacher_id`),
  UNIQUE KEY `user_id` (`user_id`),
  CONSTRAINT `teachers_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `users` (`user_id`)
) ENGINE=InnoDB AUTO_INCREMENT=2 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `teachers`
--

LOCK TABLES `teachers` WRITE;
/*!40000 ALTER TABLE `teachers` DISABLE KEYS */;
INSERT INTO `teachers` VALUES (1,4,'sana','fatima','sanacentral123@gmail.com','923150484043','Graduation','2025-12-30',0);
/*!40000 ALTER TABLE `teachers` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users`
--

DROP TABLE IF EXISTS `users`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users` (
  `user_id` int(11) NOT NULL AUTO_INCREMENT,
  `email` varchar(255) NOT NULL,
  `password` varchar(255) NOT NULL,
  `role_id` int(11) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`user_id`),
  UNIQUE KEY `email` (`email`),
  KEY `role_id` (`role_id`),
  CONSTRAINT `users_ibfk_1` FOREIGN KEY (`role_id`) REFERENCES `users_role` (`role_id`)
) ENGINE=InnoDB AUTO_INCREMENT=11 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users`
--

LOCK TABLES `users` WRITE;
/*!40000 ALTER TABLE `users` DISABLE KEYS */;
INSERT INTO `users` VALUES (1,'teacher@gmail.com','12345',1,0),(2,'student@gmail.com','54321',2,0),(3,'ullahcentral123@gmail.com','scrypt:32768:8:1$7jPlgi083yfmCTVX$09d66e8cbbcb7df85dba9cc78052ab9d547244815938d89dcbcd01f00d58ff2a7be80bd3a4ad9bc57f84125a3affb624b32a0c0c8a32e85b628f3908fdd59e4c',2,0),(4,'sanacentral123@gmail.com','scrypt:32768:8:1$S7vfbzBO2aRNJpRd$6ffe5515c5085614610d0af9e13e005cfad46755406334ec6804562c60a3511112b3f61fe9f700d8b3a6a315ec1179c8d0377dc0f9bfab76cfd3bc2db693b951',1,0),(5,'huzaifacentral123@gmail.com','scrypt:32768:8:1$I9n0FGjNKaqHRaC4$3e9a48dd81365bda10cf83a4ab1e1eab8c15ac930da13bc1742efef4f4ea57274842f7ab41d824c2c8f135c5f214071ac911d9dd1a334ff553388ab2d0369575',2,0),(6,'hammadcentral123@gmail.com','scrypt:32768:8:1$jfSOWTiPsrWqazKQ$221c31ec18f224255ea2dff9eaf531a035cf704e27918fa7e4364a89d54eeae8af42701c759ba68cd5e7f49c9cf5bb690e8768725f11e63fc7b848f0f2e3de0f',2,0),(7,'mubeenmuzaffar123@gmail.com','scrypt:32768:8:1$ZhqrixLR5MGq8CS2$163df37b57801281972e50959c569da0d91ce77390944d9c2e81729f9a8feab0e9eaa3502ff59bdc825898746268da597de329eeebc9049ff365302bcfb74634',2,0),(8,'saleemkhurram420@gmail.com','scrypt:32768:8:1$skIzf7LpmeXDV7We$46816137a770b3c6ca5f90f7a3c5e03d772807aada70e450473f15803ebf2c5793b04ca86e78101e5da1272c80919b4e8a49d2540aabc7bd51e84d68b91e5e70',3,0),(9,'hariscentral123@gmail.com','scrypt:32768:8:1$R3WyGmnp0WVq4Yr6$3f666a241ec267a81464d1b8ba5efc3937e99b14d0970339055853ed23fb6c024978199950cd6c93e3d97d00d8999db3d286b43a1bf47b30c66cc8f09b55471e',2,0),(10,'aiman123@gmail.com','scrypt:32768:8:1$5K9YM4nseB8f0CJ6$2b429fd8fcb38a2d5611110452b2f1929b785ce2923b3885fd6efa75e0740f70fa0df8f057f47292ae1ea1dcb3d6b5c1cb370e7526ae69a64a1f8e7eab00ddbb',2,0);
/*!40000 ALTER TABLE `users` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Table structure for table `users_role`
--

DROP TABLE IF EXISTS `users_role`;
/*!40101 SET @saved_cs_client     = @@character_set_client */;
/*!40101 SET character_set_client = utf8 */;
CREATE TABLE `users_role` (
  `role_id` int(11) NOT NULL AUTO_INCREMENT,
  `role_type` varchar(100) NOT NULL,
  `is_deleted` int(11) NOT NULL DEFAULT 0,
  PRIMARY KEY (`role_id`),
  UNIQUE KEY `role_type` (`role_type`)
) ENGINE=InnoDB AUTO_INCREMENT=4 DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;
/*!40101 SET character_set_client = @saved_cs_client */;

--
-- Dumping data for table `users_role`
--

LOCK TABLES `users_role` WRITE;
/*!40000 ALTER TABLE `users_role` DISABLE KEYS */;
INSERT INTO `users_role` VALUES (1,'teacher',0),(2,'student',0),(3,'admin',0);
/*!40000 ALTER TABLE `users_role` ENABLE KEYS */;
UNLOCK TABLES;

--
-- Dumping routines for database 'lms'
--
/*!40103 SET TIME_ZONE=@OLD_TIME_ZONE */;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;

-- Dump completed on 2026-03-08 10:24:20
