drop database if exists project_it202;
create database project_it202;
use project_it202;

-- 1. Thiết kế bảng
create table Customers (
    Customer_ID char(10) primary key,
    Full_Name varchar(50),
    Phone_Number varchar(20) unique,
    Email varchar(50),
    Join_Date date default (current_date)
);

create table Insurance_Packages (
    Package_ID char(10) primary key,
    Package_Name varchar(50),
    Max_Limit int check (Max_Limit > 0),
    Base_Premium int
);

create table Policies (
    Policy_ID char(10) primary key,
    Customer_ID char(10),
    Package_ID char(10),
    Start_Date date,
    End_Date date,
    Status varchar(30),
    foreign key (Customer_ID) references Customers(Customer_ID),
    foreign key (Package_ID) references Insurance_Packages(Package_ID)
);

create table Claims (
    Claim_ID char(10) primary key,
    Policy_ID char(10),
    Claim_Date date,
    Claim_Amount int check (Claim_Amount > 0),
    Status varchar(30),
    foreign key (Policy_ID) references Policies(Policy_ID)
);

create table Claim_Processing_Log (
    Log_ID char(10) primary key,
    Claim_ID char(10),
    Action_Detail varchar(50),
    Recorded_At datetime,
    Processor varchar(30),
    foreign key (Claim_ID) references Claims(Claim_ID)
);

-- 2. DML
-- a. Insert dữ liệu mẫu
insert into Customers(Customer_ID, Full_Name, Phone_Number, Email, Join_Date) values
("C001", "Nguyen Hoang Long", "0901112223", "long.nh@gmail.com", "2024-01-15"),
("C002", "Tran Thi Kim Anh", "0988877766", "anh.tk@yahoo.com", "2024-03-10"),
("C003", "Le Hoang Nam", "0903334445", "nam.lh@outlook.com", "2025-05-20"),
("C004", "Pham Minh Duc", "0355556667", "duc.pm@gmail.com", "2025-08-12"),
("C005", "Hoang Thu Thao", "0779998881", "thao.ht@gmail.com", "2026-01-01");

insert into Insurance_Packages(Package_ID, Package_Name, Max_Limit, Base_Premium) values
("PKG01", "Bảo hiểm Sức khỏe Gold", 500000000, 5000000),
("PKG02", "Bảo hiểm Ô tô Liberty", 1000000000, 15000000),
("PKG03", "Bảo hiểm Nhân thọ An Bình", 2000000000, 25000000),
("PKG04", "Bảo hiểm Du lịch Quốc tế", 100000000, 1000000),
("PKG05", "Bảo hiểm Tai nạn 24/7", 200000000, 2500000);

insert into Policies (Policy_ID, Customer_ID, Package_ID, Start_Date, End_Date, Status) values
("POL101", "C001", "PKG01", "2024-01-15", "2025-01-15", "Expired"),
("POL102", "C002", "PKG02", "2024-03-10", "2026-03-10", "Active"),
("POL103", "C003", "PKG03", "2025-05-20", "2035-05-20", "Active"),
("POL104", "C004", "PKG04", "2025-08-12", "2025-09-12", "Expired"),
("POL105", "C005", "PKG01", "2026-01-01", "2027-01-01", "Active");

insert into Claims (Claim_ID, Policy_ID, Claim_Date, Claim_Amount, Status) values
("CLM901", "POL102", "2024-06-15", 12000000, "Approved"),
("CLM902", "POL103", "2025-10-20", 50000000, "Pending"),
("CLM903", "POL101", "2024-11-05", 5500000, "Approved"),
("CLM904", "POL105", "2026-01-15", 2000000, "Rejected"),
("CLM905", "POL102", "2025-02-10", 120000000, "Approved");

insert into Claim_Processing_Log (Log_ID, Claim_ID, Action_Detail, Recorded_At, Processor) values
("L001", "CLM901", "Đã nhận hồ sơ hiện trường", "2024-06-15 09:00:00", "Admin_01"),
("L002", "CLM901", "Chấp nhận bồi thường xe tai nạn", "2024-06-20 14:30:00", "Admin_01"),
("L003", "CLM902", "Đang thẩm định hồ sơ bệnh án", "2025-10-21 10:00:00", "Admin_02"),
("L004", "CLM904", "Từ chối do lỗi cố ý của khách hàng", "2026-01-16 16:00:00", "Admin_03"),
("L005", "CLM905", "Đã thanh toán qua chuyển khoản", "2025-02-15 08:30:00", "Accountant_01");

-- - Viết câu lệnh tăng phí bảo hiểm cơ bản thêm 15% cho các gói bảo hiểm có hạn mức chi trả trên 500.000.000 VNĐ.
update Insurance_Packages
set Base_Premium = Base_Premium * 1.15
where Max_Limit > 500000000;

-- - Viết câu lệnh xóa các nhật ký xử lý bồi thường (Claim_Processing_Log) được ghi nhận trước ngày 20/6/2025.
delete from Claim_Processing_Log
where Recorded_At < '2025-06-20';

-- PHẦN 2: TRUY VẤN DỮ LIỆU CƠ BẢN
-- - Câu 1: Liệt kê thông tin các hợp đồng có trạng thái 'Active' và có ngày kết thúc trong năm 2026.
select * from Policies
where Status = 'Active' and year(End_Date) = 2026;

-- - Câu 2: Lấy thông tin khách hàng (Họ tên, Email) có tên chứa chữ 'Hoàng' và tham gia bảo hiểm từ năm 2025 trở lại đây.
select Full_Name, Email
from Customers
where Full_Name like '%Hoàng%' and Join_Date >= '2025-01-01';

-- - Câu 3: Hiển thị top 3 yêu cầu bồi thường (Claims) có số tiền được yêu cầu cao nhất, bỏ qua yêu cầu cao nhất (lấy từ vị trí số 2 đến số 4).
select * from Claims
order by Claim_Amount desc
limit 3 offset 1;

-- PHẦN 3: TRUY VẤN DỮ LIỆU NÂNG CAO
-- - Câu 1: Sử dụng JOIN để hiển thị: Tên khách hàng, Tên gói bảo hiểm, Ngày bắt đầu hợp đồng và Số tiền bồi thường (nếu có).
select c.Full_Name, ip.Package_Name, p.Start_Date, cl.Claim_Amount
from Customers c
join Policies p on c.Customer_ID = p.Customer_ID
join Insurance_Packages ip on p.Package_ID = ip.Package_ID
left join Claims cl on p.Policy_ID = cl.Policy_ID;

-- - Câu 2: Thống kê tổng số tiền bồi thường đã chi trả ('Approved') cho từng khách hàng. Chỉ hiện những người có tổng chi trả > 50.000.000 VNĐ.
select c.Full_Name, sum(cl.Claim_Amount) as Total_Approved_Amount
from Customers c
join Policies p on c.Customer_ID = p.Customer_ID
join Claims cl on p.Policy_ID = cl.Policy_ID
where cl.Status = 'Approved'
group by c.Customer_ID, c.Full_Name
having sum(cl.Claim_Amount) > 50000000;

-- - Câu 3: Tìm gói bảo hiểm có số lượng khách hàng đăng ký nhiều nhất.
select ip.Package_Name, count(distinct p.Customer_ID) as Customer_Count
from Insurance_Packages ip
join Policies p on ip.Package_ID = p.Package_ID
group by ip.Package_ID, ip.Package_Name
order by Customer_Count desc
limit 1;

-- PHẦN 4: INDEX VÀ VIEW
-- - Câu 1: Tạo Composite Index tên idx_policy_status_date trên bảng Policies cho hai cột: status và start_date.
create index idx_policy_status_date on Policies(Status, Start_Date);

-- - Câu 2: Tạo một View tên vw_customer_summary hiển thị: Tên khách hàng, Số lượng hợp đồng đang sở hữu, và Tổng phí bảo hiểm định kỳ họ phải trả.
create view vw_customer_summary as
select c.Full_Name, count(p.Policy_ID) as Total_Policies, sum(ip.Base_Premium) as Total_Premium
from Customers c
join Policies p on c.Customer_ID = p.Customer_ID
join Insurance_Packages ip on p.Package_ID = ip.Package_ID
group by c.Customer_ID, c.Full_Name;

-- PHẦN 5: TRIGGER
-- - Câu 1: Viết Trigger trg_after_claim_approved. Khi một yêu cầu bồi thường chuyển trạng thái sang 'Approved', tự động thêm một dòng vào Claim_Processing_Log với nội dung 'Payment processed to customer'.
delimiter //
create trigger trg_after_claim_approved
after update on Claims
for each row
begin
    if new.Status = 'Approved' and old.Status != 'Approved' then
        insert into Claim_Processing_Log (Log_ID, Claim_ID, Action_Detail, Recorded_At, Processor)
        values (uuid(), new.Claim_ID, 'Payment processed to customer', now(), 'System');
    end if;
end //
delimiter ;

-- - Câu 2: Viết Trigger ngăn chặn việc xóa hợp đồng nếu trạng thái của hợp đồng đó đang là 'Active'.
delimiter //
create trigger trg_prevent_policy_deletion
before delete on Policies
for each row
begin
    if old.Status = 'Active' then
        signal sqlstate '45000'
        set message_text = 'Cannot delete active policy';
    end if;
end //
delimiter ;

-- PHẦN 6: STORED PROCEDURE
-- - Câu 1: Viết Procedure sp_check_claim_limit nhận vào Mã yêu cầu bồi thường. Trả về tham số OUT message.
delimiter //
create procedure sp_check_claim_limit(in p_Claim_ID char(10), out message varchar(50))
begin
    declare v_Claim_Amount int;
    declare v_Max_Limit int;
    
    select c.Claim_Amount, ip.Max_Limit into v_Claim_Amount, v_Max_Limit
    from Claims c
    join Policies p on c.Policy_ID = p.Policy_ID
    join Insurance_Packages ip on p.Package_ID = ip.Package_ID
    where c.Claim_ID = p_Claim_ID;
    
    if v_Claim_Amount > v_Max_Limit then
        set message = 'Exceeded';
    else
        set message = 'Valid';
    end if;
end //
delimiter ;
