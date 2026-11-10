import pymysql
import tkinter as tk

class Database():
    def __init__(self):
        self.db = pymysql.connect(host='localhost', port=1111,
                                  user='root',
                                  password='null',
                                  db='project',
                                  charset='utf8')
        self.cursor = self.db.cursor(pymysql.cursors.DictCursor)


    def add_new_vendor(self, vendor_id, vendor_name):
        try:
            # CALL 명령문을 사용하여 AddNewVendor 프로시저 호출
            self.cursor.execute(f"CALL AddNewVendor({vendor_id}, '{vendor_name}')")
            self.db.commit()
            print('Vendor added successfully')
        except pymysql.Error as e:
            print(f"AddNewVendor 호출 중 오류 발생: {e}")
    

    def calculate_total_cost(self, cooking_company_id):
        try:
            # CALL 명령문을 사용하여 호출
            self.cursor.execute(f"CALL CalculateTotalCost({cooking_company_id})")
            result = self.cursor.fetchone()
            if result:
                total_cost = result['TotalCost']
                print(f"Cooking Company ID: {cooking_company_id}, Total Cost: {total_cost}")
                return total_cost
        except pymysql.Error as e:
            print(f"CalculateTotalCost 호출 중 오류 발생: {e}")
    
    
    
    def calculate_total_ingredient_quantity(self, storage_company_id):
        try:
            # Function 호출
            self.cursor.execute(f"SELECT CalculateTotalIngredientQuantity({storage_company_id}) AS TotalQuantity")
            result = self.cursor.fetchone()
            if result:
                total_quantity = result['TotalQuantity']
                print(f"Storage Company ID: {storage_company_id}, Total Ingredient Quantity: {total_quantity}")
                return total_quantity
        except pymysql.Error as e:
            print(f"CalculateTotalIngredientQuantity 호출 중 오류 발생: {e}")

# Tkinter 창 생성
root = tk.Tk()
root.title("Login Window")

# Database 클래스 인스턴스 생성
database = Database()



# calculate_ingredient_quantity 함수 정의
def calculate_ingredient_quantity(storage_company_id_entry):
    storage_company_id = int(storage_company_id_entry)
    total_quantity = database.calculate_total_ingredient_quantity(storage_company_id)
    if total_quantity is not None:
        print(f"Storage Company ID: {storage_company_id}, Total Ingredient Quantity: {total_quantity}")

# Total Cost 계산 함수 정의
def calculate_total_cost(cooking_company_id_entry):
    cooking_company_id = int(cooking_company_id_entry)
    total_cost = database.calculate_total_cost(cooking_company_id)
    if total_cost is not None:
        print(f"Cooking Company ID: {cooking_company_id}, Total Cost: {total_cost}")
        
        
        
# Vendor로 로그인 성공 시 AddNewVendor가 구현되는 tkinter 창
def vendor_login():
    # Vendor 로그인 GUI
    vendor_window = tk.Toplevel(root)
    vendor_window.title("Vendor 로그인")

    vendor_id_label = tk.Label(vendor_window, text="Vendor ID를 입력하세요:")
    vendor_id_label.pack()

    vendor_id_entry = tk.Entry(vendor_window)
    vendor_id_entry.pack()

    vendor_name_label = tk.Label(vendor_window, text="Vendor Name을 입력하세요:")
    vendor_name_label.pack()

    vendor_name_entry = tk.Entry(vendor_window)
    vendor_name_entry.pack()

    add_vendor_button = tk.Button(vendor_window, text="Vendor 등록하기", command=lambda: database.add_new_vendor(vendor_id_entry.get(), vendor_name_entry.get()))
    add_vendor_button.pack()



# Cooking Company로 로그인 시 CalculateTotalCost 구현되는 tkinter창
def cooking_company_login():
    # Cooking Company Total Cost GUI
    total_cost_window = tk.Toplevel(root)
    total_cost_window.title("Cooking Company Total Cost")

    cooking_company_id_label = tk.Label(total_cost_window, text="Cooking Company ID를 입력하세요:")
    cooking_company_id_label.pack()

    cooking_company_id_entry = tk.Entry(total_cost_window)
    cooking_company_id_entry.pack()

    calculate_button = tk.Button(total_cost_window, text="총 비용 계산", command=lambda: calculate_total_cost(cooking_company_id_entry.get()))
    calculate_button.pack()

# Storage Company로 로그인 성공 시 calculate_ingredient_quantity가 구현되는 tkinter 창
def storage_company_login():
    # Storage Company 로그인 GUI
    storage_company_window = tk.Toplevel(root)
    storage_company_window.title("Storage Company 로그인")

    storage_company_label = tk.Label(storage_company_window, text="Storage Company ID를 입력하세요:")
    storage_company_label.pack()

    storage_company_id_entry = tk.Entry(storage_company_window)
    storage_company_id_entry.pack()

    calculate_button = tk.Button(storage_company_window, text="재료량", command=lambda: calculate_ingredient_quantity(storage_company_id_entry.get()))
    calculate_button.pack()



# 로그인 체크 GUI
login_check_window = tk.Tk()
login_check_window.title("로그인 체크")

login_label = tk.Label(login_check_window, text="어떤 업체로 로그인하시겠습니까?")
login_label.pack()

vendor_button = tk.Button(login_check_window, text="Vendor", command=vendor_login)
vendor_button.pack()

cooking_company_button = tk.Button(login_check_window, text="Cooking Company", command=cooking_company_login)
cooking_company_button.pack()

storage_company_button = tk.Button(login_check_window, text="Storage Company", command=storage_company_login)
storage_company_button.pack()

# root 창 숨기기
root.withdraw()

login_check_window.mainloop()
