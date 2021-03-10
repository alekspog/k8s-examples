import requests
import time

# Access the service using DNS name
# host: http://{resource-name}.{namespace}.{resource-type}.cluster.local"
host="http://hello.hello-ns.svc.cluster.local"
port=80812

def main():
    time.sleep(5)
    session = requests.Session()
    resp = session.get(f"{host}:{port}", timeout=5)
    print(f"Status code: {resp.status_code}")

if __name__ == "__main__":
    main()
