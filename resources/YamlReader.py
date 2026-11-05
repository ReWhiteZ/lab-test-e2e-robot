import yaml
import os

def get_config_value(file_path, key_path):
    """
    อ่านค่าจากไฟล์ YAML ตาม key ที่ระบุ (รองรับ nested key เช่น 'env.url')
    """
    # 1. หา Path ปัจจุบันของไฟล์ Python นี้ (YamlReader.py)
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 2. ถอยกลับไป 1 โฟลเดอร์เพื่อไปที่ Root ของโปรเจกต์
    project_root = os.path.dirname(current_dir)
    
    # 3. ประกอบ Path เต็ม (เช่น D:\...\Lab-04_Robot_uv\config\config.yaml)
    full_path = os.path.join(project_root, file_path)

    # 4. เปิดไฟล์และอ่านข้อมูล
    with open(full_path, 'r', encoding='utf-8') as file:
        config = yaml.safe_load(file)

    # 5. แยก Key ที่ซ้อนกัน (เช่น 'env.url' จะกลายเป็น ['env', 'url'])
    keys = key_path.split('.')
    value = config
    
    # 6. วนลูปเข้าไปดึงค่าข้างใน
    for key in keys:
        # เช็กว่าค่าปัจจุบันเป็น Dictionary และมี Key นี้อยู่จริงไหม
        if isinstance(value, dict) and key in value:
            value = value[key]
        else:
            raise ValueError(f"ไม่พบ Key: '{key_path}' ในไฟล์ {file_path}")
            
    return str(value)