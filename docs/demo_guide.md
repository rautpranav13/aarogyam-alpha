# Aarogyam: Project Alpha — Live Demo & Pitch Guide

> **Official Pitch Choreography, Localhost Setup, and Evaluator Q&A Guide**  
> Tailored for the IBM SkillsBuild / SkillUp Hackathon (Week 4 Rubric)

---

## 1. Pre-Pitch Setup (T-15 Minutes SOP)

### Step 1: Boot Localhost Gateway on Demo Laptop
In your terminal, navigate to the consolidated backend:
```bash
cd backend
python app.py
```
Verify the server is running on `http://localhost:5001`. Test with:
```bash
curl http://localhost:5001/api/health
```

### Step 2: Establish the Zero-Latency Tunnel
Choose one of the following two options:

#### Option A: Cloudflare Tunnel (Recommended for Wi-Fi)
```bash
cloudflared tunnel --url http://localhost:5001
```
Copy the generated HTTPS URL (e.g., `https://xyz.trycloudflare.com`) and paste it into `aarogyam-flutter/.env`:
```env
BACKEND_URL=https://xyz.trycloudflare.com
```

#### Option B: Direct USB Reverse Tethering (100% Bulletproof — No Wi-Fi Needed)
Plug your Android phone into your laptop via USB with USB Debugging enabled:
```bash
adb reverse tcp:5001 tcp:5001
```
In your Flutter `.env`:
```env
BACKEND_URL=http://localhost:5001
```
*(Your phone now communicates directly through the USB cable with $<1\text{ ms}$ latency).*

---

## 2. The 3-Minute Winning Pitch Script

| Time | Stage Action | Spoken Script | Evaluator Lens (Week 4) |
|---|---|---|---|
| **0:00 - 0:30** | Hook & Problem | *"Over 50% of chronic patients in India do not take their medicines correctly. Why? Because doctor prescriptions are written in rushed English shorthand, while patients speak Hindi or Marathi. And for elderly patients, identical-looking blister strips lead to lethal wrong-pill mix-ups."* | **Problem Before Solution** (Slide 8): Make judges feel the clinical pain. |
| **0:30 - 0:50** | The Solution | *"Introducing Aarogyam: A privacy-first, 5-step prescription guardian powered by IBM Granite Vision 3.2 2B and Watson Speech. It decodes prescriptions, explains them in mother tongues, automates alarms, and verifies the physical blister strip before ingestion."* | **Clarity of Vision** (Slide 12): Focused, elegant, purposeful. |
| **0:50 - 1:20** | Live Demo: Steps 1 & 2 (Scan & Digitization) | *(Point camera at doctor's prescription)*<br/>*"First, our on-device privacy shield redacts the patient's name and contact before transmission. Watch as IBM Granite Vision decodes this handwriting in under two seconds: Metformin 500mg, twice daily after food."* | **Technical Implementation** (Slide 11): Live AI processing in real-time. |
| **1:20 - 1:45** | Live Demo: Step 3 (Vernacular Explainer) | *(Tap the speaker button)*<br/>*"For our elderly users who cannot read English, Aarogyam speaks in conversational Hindi:"*<br/>🔊 App: *"यह गोली सुबह और रात को खाना खाने के बाद लेनी है।"* | **User Experience & Accessibility** (Slide 11): Intuitive for non-English speakers. |
| **1:45 - 2:20** | Live Demo: Steps 4 & 5 (Alarm & Strip Verifier) | *(Show scheduled alarm, trigger test alert, point camera at medicine foil)*<br/>*"When the alarm sounds, the patient holds up their medicine strip before swallowing. Granite Vision inspects the foil printing:"*<br/>🟢 App: *"सत्यापित: मेटफॉर्मिन 500mg। कृपया इसे लें।"*<br/>*"If they hold up the wrong pill, it sounds an immediate alert."* | **The Showstopper (Closed Loop)**: Proof of consumption safety. |
| **2:20 - 3:00** | Impact, Tech & IBM Bob | *"100% offline alarm reliability, zero PII leakage, accessible across 500M+ Indic language speakers. Built, tested, and iterated end-to-end with our AI partner, IBM Bob. Thank you."* | **Impact Statement & IBM Bob** (Slide 9 & 12). |

---

## 3. Anticipated Judge Q&A Cheat Sheet

### Q1: *"What if the handwriting is so illegible that even Granite Vision cannot read it?"*
* **Answer**: *"Under IBM Responsible AI guidelines, we enforce a strict confidence threshold. If OCR confidence falls below 80%, the system flags a yellow warning: 'Unclear handwriting — please verify with your pharmacist before taking.' We never hallucinate a dosage."*

### Q2: *"Why are you doing PII redaction on the client?"*
* **Answer**: *"To comply with India's DPDP Act and HIPAA standards. By masking the patient name, phone number, and clinic address on the device before sending image bytes to the vision API, we guarantee zero personal health information leakage."*

### Q3: *"How does this scale to rural Primary Health Centres (PHCs) without internet?"*
* **Answer**: *"Once the prescription is digitized, all daily alarms and voice instructions run 100% offline from the local SQLite database. The patient needs connectivity only for the initial 2-second scan, and even that can be hosted on a low-cost edge PC in the local clinic."*

### Q4: *"How did you use IBM Bob in this project?"*
* **Answer**: *"IBM Bob was our development partner across the lifecycle: Bob helped us prune our architecture into this focused 5-step model, generated the Granite Vision prompt templates, and scaffolded the automated Flutter test suites."*
