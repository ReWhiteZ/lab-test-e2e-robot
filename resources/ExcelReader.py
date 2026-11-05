import openpyxl
import os

def get_excel_test_data(file_path):
    """
    อ่านไฟล์ Excel และคืนค่าข้อมูลออกมาเป็น List ของ Dictionary
    เพื่อให้ Robot Framework นำไปใช้ใน Loop ได้ง่ายๆ
    """
    # 1. หา Path ปัจจุบันของโฟลเดอร์ resources
    current_dir = os.path.dirname(os.path.abspath(__file__))
    
    # 2. ถอยกลับไป 1 โฟลเดอร์เพื่อไปที่ Root
    project_root = os.path.dirname(current_dir)
    
    # 3. ประกอบ Path เต็มของไฟล์ Excel
    full_path = os.path.join(project_root, file_path)

    # 4. เปิดไฟล์ Excel
    wb = openpyxl.load_workbook(full_path)
    ws = wb.active

    # 5. ดึงชื่อคอลัมน์จากแถวแรก (Row 1)
    headers = [cell.value for cell in ws[1]]
    test_data = []

    # 6. วนลูปอ่านข้อมูลตั้งแต่แถวที่ 2 เป็นต้นไป
    for row in ws.iter_rows(min_row=2, values_only=True):
        if row[0] is None: # ข้ามแถวที่ว่างเปล่า
            continue
        
        row_dict = {}
        for i, header in enumerate(headers):
            # ถ้าช่องไหนเป็น None (ว่าง) ให้เปลี่ยนเป็น String ว่าง ""
            val = row[i] if i < len(row) else None
            row_dict[header] = str(val) if val is not None else ""
            
        test_data.append(row_dict)

    return test_data