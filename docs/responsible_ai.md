# Aarogyam: Responsible AI & Clinical Ethics Framework

> **Compliance & Alignment Document**  
> Based on IBM SkillsBuild Week 2 Framework (*Divyasree PS, IBM India*)

---

## 1. Executive Summary
In healthcare, irresponsible AI can cause catastrophic real-world harm. Aarogyam is built from the ground up to embody the core principles of **Trustworthy & Responsible AI**: **Privacy, Fairness, Security, Human Oversight, and Transparency**.

---

## 2. Pillar-by-Pillar Alignment

```
┌────────────────────────────────────────────────────────────────────────┐
│                    AAROGYAM RESPONSIBLE AI FRAMEWORK                   │
│                                                                        │
│   PRIVACY             FAIRNESS            HUMAN OVERSIGHT  SAFETY      │
│   • Client-side PII   • Vernacular Hindi  • User Confirm   • Anti-     │
│     Redaction           & Marathi           Card             hallucina-│
│   • No storage of     • Senior-friendly   • Blister Strip    tion prompt│
│     raw Rx images       high-contrast UI    Verification   • Clinical  │
│                                                              disclaimer │
└────────────────────────────────────────────────────────────────────────┘
```

### 1. Privacy & Data Protection (Week 2, Slide 20)
* **The Mandate**: *"Patient health records or medical data should NEVER be entered into public/unprotected AI systems."*
* **Aarogyam Implementation**:
  * **On-Device PII Redactor**: Patient names, phone numbers, addresses, and hospital registration numbers are masked on the handset using client-side image processing *before* any byte is transmitted to IBM WatsonX.
  * **Zero Image Retention**: Prescription images are processed in-memory and are never stored on public disks.
  * **Localhost / Edge Gateway**: In a clinical deployment, images stay within the local clinic network.

### 2. Bias, Fairness & Inclusivity (Week 2, Slide 15-17)
* **The Mandate**: *"Avoid biased outcomes that disadvantage specific groups or communities."*
* **Aarogyam Implementation**:
  * **Language Equity**: Most health tools are built exclusively in English for urban users. Aarogyam democratizes care by supporting **Hindi and Marathi** natively via IBM Watson TTS.
  * **Accessibility for the Visually Impaired & Illiterate**: By delivering voice-first dosage instructions ("Dadi-Ma Mode") and large, high-contrast visual cues, illiterate and elderly users have equal access to clinical adherence tools.

### 3. Human Oversight & Accountability (Week 2, Slide 10 & 13)
* **The Mandate**: *"Humans remain accountable — AI supports decisions, never replaces judgment."*
* **Aarogyam Implementation**:
  * **No Autonomous Prescribing**: Aarogyam never diagnoses conditions or alters dosages; it only transcribes and schedules what a licensed human physician has already prescribed.
  * **User Confirmation Step**: After digitization, the patient or caretaker must review and tap "Confirm Schedule" before alarms are registered.
  * **Closed-Loop Blister Verification**: The app actively verifies the physical blister strip packaging before consumption, acting as an extra pair of eyes for the patient.

### 4. Hallucination Mitigation & Clinical Accuracy (Week 2, Slide 21)
* **The Mandate**: *"AI predicts the next likely word — it doesn't 'know' facts. Hallucinated content can cause serious harm."*
* **Aarogyam Implementation**:
  * **Deterministic Temperature ($0.0$)**: IBM Granite Vision is invoked with greedy/deterministic decoding to prevent creative or hallucinated drug names.
  * **Confidence Guardrails**: When OCR clarity is questionable, the model outputs `"confidence": "low"` and prompts the patient to consult their pharmacist rather than guessing.
  * **Strict JSON Schema Enforcement**: The vision output is constrained to pre-validated medicine parameters (Name, Dosage, 24-hr Time).

### 5. Transparency & Medical Disclaimers (Week 2, Slide 10)
* **The Mandate**: *"Be clear when AI has been used in creating content or decisions."*
* **Aarogyam Implementation**:
  * Persistent, prominent AI disclaimer visible on the scan and home screens:
    > *"Aarogyam is an AI transcription and adherence aid. Always verify unfamiliar medications with your licensed physician or pharmacist."*
