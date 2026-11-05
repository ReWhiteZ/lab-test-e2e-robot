*** Settings ***
Library           SeleniumLibrary
Library           ../resources/ExcelReader.py
Library           ../resources/YamlReader.py

*** Variables ***
# Locators หน้า Login
${USERNAME_FIELD}       id:user-name
${PASSWORD_FIELD}       id:password
${LOGIN_BUTTON}         id:login-button
${ERROR_MESSAGE}        css:h3[data-test="error"]

# Locators หน้า Cart & Checkout
${CART_ICON}            class:shopping_cart_link
${CHECKOUT_BUTTON}      id:checkout
${FIRST_NAME_FIELD}     id:first-name
${LAST_NAME_FIELD}      id:last-name
${POSTAL_CODE_FIELD}    id:postal-code
${CONTINUE_BUTTON}      id:continue
${FINISH_BUTTON}        id:finish
${COMPLETE_HEADER}      class:complete-header

*** Test Cases ***
Run All Scenarios Data-Driven
    [Documentation]    รัน Test Case ทั้งหมดโดยดึงข้อมูลจาก Excel (Data-Driven)
    ${all_data}=    Get Excel Test Data    data/test_data.xlsx
    
    FOR    ${row}    IN    @{all_data}
        Log    ====================================================
        Log    กำลังรัน: ${row}[testcase_name]
        Run Scenario According To Data    ${row}
    END

*** Keywords ***
Run Scenario According To Data
    [Arguments]    ${data}
    [Documentation]    แยกแยะ Logic ตามชื่อ Scenario ใน Excel
    Open Browser To SauceDemo
    Login To SauceDemo    ${data}[username]    ${data}[password]

    # --- Scenario 2: Negative Case (Locked User) ---
    IF    '${data}[testcase_name]' == 'Negative_Locked_User'
        Verify Message    ${data}[expected_result]    ${True}
        Close Browser
        RETURN
    END

    # --- เพิ่มสินค้าและไปหน้า Checkout ---
    Add Items To Cart    ${data}[items_to_add]
    Go To Cart And Checkout
    Fill Checkout Information    ${data}[first_name]    ${data}[last_name]    ${data}[postal_code]

    # --- Scenario 2: Negative Case (Missing Postal Code) ---
    IF    '${data}[testcase_name]' == 'Negative_Missing_Postal_Code'
        Verify Message    ${data}[expected_result]    ${True}
    # --- Scenario 1: End-to-End Successful Purchase ---
    ELSE
        Confirm Order
        Verify Message    ${data}[expected_result]    ${False}
    END

    Close Browser

Open Browser To SauceDemo
    [Documentation]    เปิดเบราว์เซอร์ตามค่าที่ตั้งไว้ใน config.yaml
    ${url}=       Get Config Value    config/config.yaml    env.url
    ${browser}=   Get Config Value    config/config.yaml    env.browser
    ${headless}=  Get Config Value    config/config.yaml    env.headless
    
    # แปลง String เป็น Boolean
    ${is_headless}=    Evaluate    True if "${headless}".lower() == "true" else False
    
    # เปิด Browser แบบแยกเงื่อนไข เพื่อความเสถียร
    IF    ${is_headless}
        Open Browser    ${url}    ${browser}    options=add_argument("--headless");add_argument("--window-size=1920,1080")
    ELSE
        Open Browser    ${url}    ${browser}
        Maximize Browser Window
    END

Login To SauceDemo
    [Arguments]    ${username}    ${password}
    Wait Until Element Is Visible    ${USERNAME_FIELD}    timeout=10s
    Input Text       ${USERNAME_FIELD}    ${username}
    Input Text       ${PASSWORD_FIELD}    ${password}
    Click Button     ${LOGIN_BUTTON}

Add Items To Cart
    [Arguments]    ${items_string}
    [Documentation]    รับชื่อสินค้าคั่นด้วย comma และทำการกดเพิ่มลงตะกร้าทีละชิ้น
    @{items}=    Evaluate    [item.strip() for item in "${items_string}".split(",") if item.strip()]
    
    FOR    ${item}    IN    @{items}
        ${add_to_cart_btn}=    Set Variable    xpath://div[text()="${item}"]/ancestor::div[@class="inventory_item"]//button
        Wait Until Element Is Visible    ${add_to_cart_btn}    timeout=10s
        Click Element    ${add_to_cart_btn}
    END

Go To Cart And Checkout
    Click Element    ${CART_ICON}
    Wait Until Element Is Visible    ${CHECKOUT_BUTTON}    timeout=10s
    Click Element    ${CHECKOUT_BUTTON}

Fill Checkout Information
    [Arguments]    ${first_name}    ${last_name}    ${postal_code}
    Wait Until Element Is Visible    ${FIRST_NAME_FIELD}    timeout=10s
    Input Text    ${FIRST_NAME_FIELD}    ${first_name}
    Input Text    ${LAST_NAME_FIELD}    ${last_name}
    
    IF    "${postal_code}" != ""
        Input Text    ${POSTAL_CODE_FIELD}    ${postal_code}
    END
    Click Element    ${CONTINUE_BUTTON}

Confirm Order
    Wait Until Element Is Visible    ${FINISH_BUTTON}    timeout=10s
    Click Element    ${FINISH_BUTTON}

Verify Message
    [Arguments]    ${expected_text}    ${is_error}=False
    [Documentation]    ตรวจสอบข้อความ Success หรือ Error ว่าตรงกับที่คาดหวังหรือไม่
    IF    ${is_error}
        Wait Until Element Is Visible    ${ERROR_MESSAGE}    timeout=10s
        ${actual_text}=    Get Text    ${ERROR_MESSAGE}
    ELSE
        Wait Until Element Is Visible    ${COMPLETE_HEADER}    timeout=10s
        ${actual_text}=    Get Text    ${COMPLETE_HEADER}
    END
    
    Should Contain    ${actual_text}    ${expected_text}