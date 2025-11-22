import socket

def scan(target, ports):
    print('\n' + 'Starting Scan for ' + str(target))
    for port in range(1, ports + 1):
        scan_port(target, port)

def scan_port(ipaddress, port):
    try:
        sock = socket.socket()
        sock.settimeout(0.5)
        sock.connect((ipaddress, port))
        print(f"[+] Port open {port}")
        sock.close()
    except:
        pass

targets = input('[*] Enter targets to scan (split them by ,): ')
ports = int(input('[*] Enter how many ports you want to scan: '))

if ',' in targets:
    print('[*] Scanning multiple targets')
    for ip_addr in targets.split(','):
        scan(ip_addr.strip(), ports)
else:
    scan(targets, ports)
