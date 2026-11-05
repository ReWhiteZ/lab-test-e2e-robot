import openpyxl
import os

# สร้างโฟลเดอร์ data ถ้ายังไม่มี
os.makedirs("data", exist_ok=True)

# สร้าง Workbook ใหม่
wb = openpyxl.Workbook()
ws = wb.active
ws.title = "TestData"

# กำหนดหัวตาราง (Columns) ตามโจทย์
headers = [
    "testcase_name", 
    "username", 
    "password", 
    "items_to_add", 
    "first_name", 
    "last_name", 
    "postal_code", 
    "expected_result"
]
ws.append(headers)

# ข้อมูลทดสอบ (Test Data)
test_data = [
    # --- Scenario 1: End-to-End Successful Purchase ---
    [
        "E2E_Purchase_Single_Item",
        "standard_user",
        "secret_sauce",
        "Sauce Labs Backpack",
        "John",
        "Doe",
        "11000",
        "Thank you for your order!"
    ],
    [
        "E2E_Purchase_Multiple_Items",
        "standard_user",
        "secret_sauce",
        "Sauce Labs Backpack, Sauce Labs Bike Light, Sauce Labs Onesie",
        "Jane",
        "Smith",
        "20000",
        "Thank you for your order!"
    ],
    # --- Scenario 2: Negative Case ---
    [
        "Negative_Locked_User",
        "locked_out_user",
        "secret_sauce",
        "", # ไม่ได้ซื้อของ
        "",
        "",
        "",
        "Epic sadface: Sorry, this user has been locked out."
    ],
    [
        "Negative_Missing_Postal_Code",
        "standard_user",
        "secret_sauce",
        "Sauce Labs Bolt T-Shirt",
        "Alice",
        "Wonder",
        "", # จงใจไม่ใส่รหัสไปรษณีย์
        "Error: Postal Code is required"
    ]
]

# เพิ่มข้อมูลลงในไฟล์
for row in test_data:
    ws.append(row)

# จัดความกว้างคอลัมน์ให้อ่านง่าย
for col in ws.columns:
    max_length = 0
    column = col[0].column_letter
    for cell in col:
        try:
            if len(str(cell.value)) > max_length:
                max_length = len(str(cell.value))
        except:
            pass
    ws.column_dimensions[column].width = max_length + 2

# บันทึกไฟล์
file_path = "data/test_data.xlsx"
wb.save(file_path)
print(f"✅ สร้างไฟล์ {file_path} สำเร็จเรียบร้อยแล้ว!")