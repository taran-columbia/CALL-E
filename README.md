# Call-E

Call-E is a mobile application designed to make calling **simple and accessible** for users who may not be tech-savvy. It enables **one-tap calling** through multiple modes:  
- Traditional calls  
- WhatsApp voice calls  
- WhatsApp video calls  

Instead of scrolling through long contact lists, users can quickly identify and reach important contacts via images. To ensure privacy, all contacts and sensitive data are stored locally on the device using **SQLite**.  

---

## Demo  

Here’s a quick preview of Call-E in action:  

![App Demo](assets/CallE.gif)  

---

## Features (Version 2)  
- **Contact Management (CRUD):** Add, edit, and manage caller details from the device’s contact list  
- **Multi-Mode Calling:** Place calls via traditional, WhatsApp voice, or WhatsApp video with a single tap  
- **Missed Calls Overview:** Displays the 5 most recent missed calls with direct call-back options  
- **Privacy-Focused:** No external servers — user data stays on the device  

---

## Tech Stack  
- **Framework:** Flutter (Dart)  
- **Database:** SQLite  
- **Platform:** Android  
- **Additional Tools:** Kotlin + Android Accessibility Services for call automation  

---

## Challenges & Solutions  
- **Challenge:** Non-Business version of WhatsApp restricts external apps from initiating calls directly.  
- **Solution:** Used **Android Accessibility Services** in combination with **Kotlin** to automate and enable one-tap call initiation.  

---

## Roadmap (Work in Progress)  
- Support for **iOS devices**  
- Integration of **Large Language Models (LLMs)** to provide guided assistance and smart recommendations for users  

---

## Project Background  
- **Version 1:** Limited beta release for a closed group of users (not publicly available)  
- **Version 2:** Current active version with new features, privacy-first approach, and enhanced usability  

---

## Connect  
For ideas, feedback, or collaboration opportunities:  
- **LinkedIn:** [Tarandeep Singh](https://www.linkedin.com/in/tarandeep-singh-columbia/)  

---

*Call-E is built with the vision of making communication more intuitive, inclusive, and accessible for everyone.*  
