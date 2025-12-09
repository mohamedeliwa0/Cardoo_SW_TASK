#!/usr/bin/env python3
# Optimized DHT_With_BLE_Script.py

import time
import threading
from bluezero import peripheral, adapter
import adafruit_dht
import board

# ===== BLE CONFIG =====
LOCAL_NAME = 'PiSensor'
SERVICE_UUID = '12345678-1234-5678-1234-56789abcdef0'
CHAR_UUID = '87654321-4321-6789-4321-fedcba987654'

# ===== SENSOR CONFIG =====
SENSOR_PIN = board.D4       # DHT11 on GPIO4
READ_INTERVAL = 3           # Seconds

latest_str = "init"

# Initialize DHT11
dht = adafruit_dht.DHT11(SENSOR_PIN, use_pulseio=False)

# -------- SENSOR READING THREAD --------
def read_sensor():
    global latest_str
    while True:
        try:
            t = dht.temperature
            h = dht.humidity
            if t is None or h is None:
                raise RuntimeError("Sensor returned None")
            latest_str = f"T:{t:.1f}C H:{h:.1f}%"
        except Exception as e:
            latest_str = f"ERR:{str(e)}"
        time.sleep(READ_INTERVAL)

# -------- GATT READ CALLBACK --------
def read_callback():
    return bytearray(latest_str, "utf-8")

# -------- MAIN BLE SETUP --------
def main():
    # Start sensor thread
    threading.Thread(target=read_sensor, daemon=True).start()

    # Setup BLE peripheral
    my_periph = peripheral.Peripheral(
        adapter_address=adapter.list_adapters()[0],
        local_name=LOCAL_NAME
    )

    # Add service
    my_periph.add_service(
        srv_id=1,
        uuid=SERVICE_UUID,
        primary=True
    )

    # Add characteristic
    my_periph.add_characteristic(
        srv_id=1,
        chr_id=1,
        uuid=CHAR_UUID,
        value=[],
        notifying=False,
        flags=['read', 'notify'],
        read_callback=read_callback
    )

    my_periph.publish()
    print(f"BLE started as '{LOCAL_NAME}'. Waiting for connection...")

    previous = ""
    try:
        while True:
            if latest_str != previous:
                previous = latest_str
                print("New reading:", latest_str)

                # Update characteristic value
                my_periph.update_char_value(
                    srv_id=1,
                    chr_id=1,
                    value=bytearray(latest_str, "utf-8")
                )
                # Notify subscribers
                my_periph.notify(srv_id=1, chr_id=1)

            time.sleep(0.8)  # Reduced CPU usage

    except KeyboardInterrupt:
        print("Stopping BLE...")
        my_periph.stop()

if __name__ == "__main__":
    main()
