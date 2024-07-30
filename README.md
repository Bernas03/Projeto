
# Telemedicine Monitoring System

## Overview
This project involves the development of a telemedicine system for remote patient monitoring. It comprises a mobile application for collecting biometric data from an ECG sensor, a web application for caregivers to access and analyze data, and a remote database for storing all collected information.

## Objectives
- **Main Objective:** Develop a telemedicine system for remote patient monitoring.
- **Sub-Objectives:**
  - Develop a mobile app to collect biometric data from an ECG sensor.
  - Create a web app for caregivers to access and manage patient data.
  - Implement a remote database for data storage and communication.
  - Ensure efficient and secure data transmission between the sensor, mobile app, and web app.
  - Develop an intuitive user interface for both applications.
  - Ensure data security and privacy throughout the system.

## Technologies and Tools
- **Okeanos Global:** Hosting for the remote database, API, and web application.
- **Flutter:** Framework for developing the mobile application.
- **MySQL:** Database management system.
- **FastAPI:** Backend framework for the API.
- **BITalino:** ECG sensor for data collection.
- **Android Studio & Visual Studio Code:** Development environments.
- **Figma & Draw.io:** Tools for UI/UX design and diagram creation.
- **LaTeX:** Document preparation system for the project report.

## System Architecture
The system consists of three main components:
1. **Mobile Application:** Collects biometric data from the ECG sensor and transmits it to the remote database.
2. **Web Application:** Allows caregivers to access, manage, and analyze the collected data.
3. **Remote Database:** Stores all the collected data and facilitates communication between the mobile and web applications.

## Implementation
1. **Database Setup:**
   - Hosted on Okeanos Global using MySQL.
   - Structured to ensure efficient data storage and retrieval.

2. **API Implementation:**
   - Developed using FastAPI.
   - Facilitates communication between the mobile app, web app, and database.

3. **Mobile Application:**
   - Developed using Flutter.
   - Integrates with the BITalino ECG sensor via Bluetooth.
   - Provides a user-friendly interface for patients to input and transmit their biometric data.

4. **Web Application:**
   - Provides caregivers with tools to manage patient data.
   - Developed with a focus on usability and accessibility.

## Testing
- Conducted unit and integration tests to ensure functionality, performance, and reliability.
- Continuous testing throughout development to identify and resolve issues promptly.

## How to Use
1. **Mobile App:**
   - Download and install the app on your mobile device.
   - Pair the app with the BITalino ECG sensor via Bluetooth.
   - Log in using the provided access code.
   - Start collecting and transmitting biometric data.

2. **Web App:**
   - Access the web application through the provided URL.
   - Log in with caregiver credentials.
   - View and manage patient data, and analyze collected biometric information.

## Acknowledgements
This project was developed as part of the Engineering Informatics course at the University of Beira Interior under the guidance of Professor Dr. Bruno Silva.
