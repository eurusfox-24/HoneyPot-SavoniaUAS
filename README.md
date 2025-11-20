# 🔒 Isolated Network Security Lab  
### Raspberry Pi 5 Honeypot & Penetration Testing Environment

This repository stores all **configuration files, custom scripts, and reference materials** used in an isolated network security lab built entirely on Raspberry Pi 5 devices.

> ⚠️ **Note:**  
> The files in this repo **cannot** be cloned to instantly reproduce the full physical setup. This repository contains only the *digital* assets required for the environment (scripts, configs, docs).

---

## 🎯 Project Overview: Honeypot Simulation

The goal of this project is to simulate a contained, offline network environment for observing and logging penetration-testing activities against a controlled honeypot system. All activities are performed on **four isolated Raspberry Pi 5 devices**, each with a specialized role.

This environment is for **educational and ethical use only**.

---

## 🏗️ Network Architecture Summary

The network operates as a **fully isolated wireless subnet**, disconnected from the internet to ensure absolute containment of all testing activities.

<!-- Network Topology Diagram Placeholder -->

### Device Roles

| Device | Operating System | Role |
|--------|------------------|------|
| **Hacking Machine** | Parrot OS (or Kali/Raspbian) | Runs penetration testing tools and scripts. |
| **Honeypot System (HoneyPi)** | HoneyPi | Passive monitoring, logging, and intrusion detection. |
| **Network Router** | OpenWrt | Creates an isolated offline wireless subnet. |
| **Web Server** | NGINX on Raspberry Pi OS | Static reference web server (not targeted). |

---

## 🛠️ Key Components & Activities

### 1. **Isolated Subnet (OpenWrt Router)**  
A Raspberry Pi 5 running OpenWrt creates a **self-contained, offline Wi-Fi network**.  
This ensures that testing cannot leak into external networks or devices.

---

### 2. **Attacker Machine (Parrot OS)**  
Used to simulate controlled attacks on the honeypot:

#### 🔍 Port Scanning  
A custom Python script (included in this repo) scans the HoneyPi's open ports.

#### 🔐 Telnet Brute Force  
Hydra is used to attempt Telnet login brute-force attacks on port 23.

---

### 3. **Target System — HoneyPi Honeypot**  
HoneyPi simulates low-interaction vulnerabilities and logs attacker behavior.

#### Vulnerability Status Table

| Vulnerability | Status | Description |
|---------------|--------|-------------|
| **Port Scanning** | ACTIVE | Logs all port scan attempts. |
| **Telnet** | ACTIVE | Detects and logs Telnet brute-force attempts. |
| **FTP** | INACTIVE | Supported, but not tested in this phase. |
| **VNC** | INACTIVE | Supported, but not tested in this phase. |

---

### 4. **Logging & Reporting System**

HoneyPi provides immediate documentation of attack activity:

- 📜 **Real-time Logging:**  
  Every port scan and Telnet attempt is captured.

- ✉️ **Email Notification System:**  
  Logs are parsed, summarized, and automatically emailed to a dedicated inbox for offline evidence collection.

---

### 5. **Reference Web Server (NGINX)**

A separate Raspberry Pi 5 hosts a simple static website via NGINX.  
This device serves only as a realistic model in the network and is **not targeted** during tests.

---

## 📦 Portability & Enclosure

All four Raspberry Pi 5 devices are mounted inside a **custom 3D-printed enclosure**, making the entire lab portable for demonstrations and educational workshops.

---

