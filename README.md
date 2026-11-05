# Lab 04 — Data-driven E2E ด้วย Robot Framework

โปรเจกต์ตัวอย่างสำหรับจัดการ browser test ด้วย Robot Framework และ SeleniumLibrary พร้อมแยก configuration เป็น YAML, test data เป็น Excel และอ่านไฟล์ด้วย Python library ของ Robot Framework คู่มือนี้อธิบายการสร้างโครงสร้างลักษณะนี้ตั้งแต่ต้นและแนวทางออกแบบ test โดยใช้ framework และภาษาเป็นหลัก

## สิ่งที่ต้องมี

- Python 3.14 ขึ้นไป
- `uv`
- Google Chrome หรือ Chromium
- สำหรับสร้างรายงานจากข้อมูลตัวอย่าง อาจใช้ Excel/โปรแกรมอ่านไฟล์ `.xlsx` ใดก็ได้

ติดตั้ง `uv` ตามเอกสารทางการ และตรวจสอบด้วย `uv --version` กับ `python --version`

## สร้างโปรเจกต์จากศูนย์

สร้างแพ็กเกจ Python พร้อม source layout แล้วเพิ่ม dependencies:

```powershell
uv init --package --python 3.14 e2e-robot-project
cd e2e-robot-project
uv add robotframework robotframework-seleniumlibrary openpyxl pyyaml
New-Item -ItemType Directory tests, resources, config, data, results
```

จัดไฟล์ให้อยู่ในตำแหน่งที่อ่านและดูแลต่อได้:

```text
e2e-robot-project/
├── config/
│   └── config.yaml
├── data/
│   └── test_data.xlsx
├── resources/
│   ├── ExcelReader.py
│   └── YamlReader.py
├── src/e2e_robot_project/
├── tests/
│   └── test_scenarios.robot
├── results/                 # ผลลัพธ์ที่สร้างจากการรัน
├── pyproject.toml
└── uv.lock
```

ไฟล์ `pyproject.toml` เก็บ dependencies, `uv.lock` ล็อกเวอร์ชัน, `config.yaml` เก็บค่าตั้งต้น เช่น URL/browser/headless, Excel เก็บแถวข้อมูลสำหรับแต่ละ scenario และ Python libraries ใน `resources/` ทำหน้าที่แปลงข้อมูลภายนอกให้ Robot ใช้ได้

## เขียน test แบบ data-driven

1. สร้าง `*** Settings ***` เพื่อโหลด SeleniumLibrary และ custom library จาก `resources/`
2. ระบุ locator และค่าคงที่ที่ใช้ร่วมกันใน `*** Variables ***`
3. สร้าง test case ที่อ่านแถวข้อมูล เช่น เรียก `Get Excel Test Data` แล้ววนด้วย `FOR ... IN`
4. ส่ง dictionary ของแต่ละแถวเข้า keyword ที่เตรียม browser, ทำ action และตรวจผล
5. ใช้ `IF/ELSE` เมื่อแต่ละ scenario ต้องเดิน flow ต่างกัน และใช้ assertion เช่น `Should Contain` หรือ `Should Be Equal As Numbers` ตรวจผล

ตัวอย่างแนวคิด (ชื่อ Library/keyword ต้องสอดคล้องกับ Python module ที่สร้าง):

```robot
*** Settings ***
Library    SeleniumLibrary
Library    ../resources/CsvReader.py
Test Teardown    Close All Browsers

*** Test Cases ***
Run Rows From Test Data
    @{rows}=    Read Test Data    data/test_data.csv
    FOR    ${row}    IN    @{rows}
        Run One Scenario    ${row}
    END
```

การแยก action เป็น keyword เช่น `Open Browser To Application`, `Sign In`, `Submit Form` และ `Verify Result` ทำให้ test case อ่านเป็นขั้นตอนระดับสูง ส่วน custom Python library ใช้เชื่อมข้อมูลหรือเขียนงานที่ทำใน Robot ยากกว่า โดยชื่อฟังก์ชัน Python จะกลายเป็น keyword ให้ Robot เรียก

## โครงสร้างข้อมูลและ configuration

- YAML เหมาะกับค่าตั้งต้นแบบ key/value และ key ซ้อน เช่น `env.url`
- Excel/CSV เหมาะกับหลายแถวข้อมูลที่ใช้รัน scenario เดิมซ้ำด้วย input ต่างกัน
- แยก test data ออกจากขั้นตอน ช่วยเพิ่ม scenario โดยไม่ต้องคัดลอก test flow
- อย่าใส่ secret จริงในไฟล์ที่ commit และควรตรวจสอบ input ที่อ่านมาก่อนนำไปใช้

Lab นี้มี `generate_test_data.py` สำหรับสร้างไฟล์ Excel ตัวอย่าง:

```powershell
uv run python generate_test_data.py
```

## ติดตั้งและรันโปรเจกต์นี้

```powershell
uv sync
uv run python generate_test_data.py
uv run robot --outputdir results tests
```

หากสร้าง `data/test_data.xlsx` ไว้แล้ว สามารถข้ามการสร้างไฟล์ใหม่ได้ รายงานจะอยู่ใน `results/` โดยดูภาพรวมที่ `report.html` และรายละเอียดแต่ละ keyword ที่ `log.html`

## แนวทางที่ควรทำ

- แบ่ง responsibilities ระหว่าง test flow, reusable keywords, custom libraries, configuration และ test data
- ให้ชื่อ test case และ keyword อธิบายเจตนาการทดสอบ
- ใช้ teardown สำหรับปิด browser แม้ scenario จะ fail
- ออกแบบข้อมูลให้ครอบคลุมกรณีปกติและกรณีผิดพลาด โดยผลที่คาดหวังชัดเจน
- เก็บผลลัพธ์การรันในโฟลเดอร์ที่ไม่ปะปนกับ source code
