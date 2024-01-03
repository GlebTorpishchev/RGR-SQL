-- Создание таблицы Клиенты
CREATE TABLE Clients (
    ClientID INT PRIMARY KEY,
    Name VARCHAR(100),
    ContactInfo VARCHAR(100),
    Address VARCHAR(255)
);

-- Создание таблицы Сотрудники
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    Name VARCHAR(100),
    Position VARCHAR(50),
    ContactInfo VARCHAR(100)
);

-- Создание таблицы Услуги
CREATE TABLE Services (
    ServiceID INT PRIMARY KEY,
    ServiceName VARCHAR(100),
    Description TEXT,
    Price DECIMAL(10, 2)
);

-- Создание таблицы Заказы
CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    ClientID INT,
    EmployeeID INT,
    Date DATE,
    Status VARCHAR(50),
    TotalAmount DECIMAL(10, 2),
    PaymentStatus VARCHAR(50),
    FOREIGN KEY (ClientID) REFERENCES Clients(ClientID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID)
);

-- Создание таблицы Услуги в заказе
CREATE TABLE OrderServices (
    OrderID INT,
    ServiceID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ServiceID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ServiceID) REFERENCES Services(ServiceID)
);

-- Создание таблицы Оплаты
CREATE TABLE Payments (
    PaymentID INT PRIMARY KEY,
    OrderID INT,
    Amount DECIMAL(10, 2),
    PaymentDate DATE,
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Триггер на внесение заказа с несуществующим клиентом
CREATE TRIGGER trg_InsertOrder_ClientCheck
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Clients WHERE ClientID = NEW.ClientID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Несуществующий клиент. Пожалуйста, проверьте данные заказа.';
    END IF;
END;

-- Триггер на внесение услуги в заказ с несуществующей услугой
CREATE TRIGGER trg_InsertOrderService_ServiceCheck
BEFORE INSERT ON OrderServices
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Services WHERE ServiceID = NEW.ServiceID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Несуществующая услуга. Пожалуйста, проверьте данные заказа.';
    END IF;
END;

-- Триггер на внесение оплаты с несуществующим заказом
CREATE TRIGGER trg_InsertPayment_OrderCheck
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NOT EXISTS (SELECT 1 FROM Orders WHERE OrderID = NEW.OrderID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Несуществующий заказ. Пожалуйста, проверьте данные оплаты.';
    END IF;
END;

-- Триггер на внесение заказа с неположительной суммой
CREATE TRIGGER trg_InsertOrder_NonPositiveAmount
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    IF NEW.TotalAmount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Сумма заказа должна быть положительной.';
    END IF;
END;

-- Триггер на внесение оплаты с неположительной суммой
CREATE TRIGGER trg_InsertPayment_NonPositiveAmount
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Сумма оплаты должна быть положительной.';
    END IF;
END;

-- Триггер на внесение заказа без указания сотрудника
CREATE TRIGGER trg_InsertOrder_EmployeeNotNull
BEFORE INSERT ON Orders
FOR EACH ROW
BEGIN
    IF NEW.EmployeeID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Необходимо указать сотрудника для заказа.';
    END IF;
END;

-- Триггер на внесение оплаты без указания заказа
CREATE TRIGGER trg_InsertPayment_OrderNotNull
BEFORE INSERT ON Payments
FOR EACH ROW
BEGIN
    IF NEW.OrderID IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Необходимо указать заказ для оплаты.';
    END IF;
END;

-- Триггер на изменение статуса заказа, запрещающий изменение после завершения
CREATE TRIGGER trg_UpdateOrder_StatusCheck
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Завершен' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя изменить заказ после завершения.';
    END IF;
END;

-- Триггер на изменение количества услуг в заказе, запрещающий уменьшение количества
CREATE TRIGGER trg_UpdateOrderService_QuantityCheck
BEFORE UPDATE ON OrderServices
FOR EACH ROW
BEGIN
    IF NEW.Quantity < OLD.Quantity THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя уменьшить количество услуг в заказе.';
    END IF;
END;

-- Триггер на изменение статуса оплаченного заказа
CREATE TRIGGER trg_UpdateOrder_PaidStatus
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.PaymentStatus = 'Оплачен' AND NEW.Status != 'Завершен' THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя изменить статус оплаченного заказа, кроме как на "Завершен".';
    END IF;
END;

-- Триггер на изменение суммы оплаты
CREATE TRIGGER trg_UpdatePayment_AmountCheck
BEFORE UPDATE ON Payments
FOR EACH ROW
BEGIN
    IF NEW.Amount <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Сумма оплаты должна быть положительной.';
    END IF;
END;

-- Триггер на изменение даты завершенного заказа
CREATE TRIGGER trg_UpdateOrder_CompletedOrderDate
BEFORE UPDATE ON Orders
FOR EACH ROW
BEGIN
    IF OLD.Status = 'Завершен' AND NEW.Date != OLD.Date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя изменить дату завершенного заказа.';
    END IF;
END;

-- Триггер на изменение позиции в заказе
CREATE TRIGGER trg_UpdateOrderService_PositionCheck
BEFORE UPDATE ON OrderServices
FOR EACH ROW
BEGIN
    IF NEW.Quantity < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Количество услуг в заказе не может быть отрицательным.';
    END IF;
END;


-- Триггер на удаление клиента, запрещающий удаление существующих заказов
CREATE TRIGGER trg_DeleteClient_OrderCheck
BEFORE DELETE ON Clients
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Orders WHERE ClientID = OLD.ClientID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя удалить клиента, у которого есть заказы.';
    END IF;
END;

-- Триггер на удаление услуги, запрещающий удаление используемых в заказах
CREATE TRIGGER trg_DeleteService_OrderServiceCheck
BEFORE DELETE ON Services
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM OrderServices WHERE ServiceID = OLD.ServiceID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя удалить услугу, используемую в заказах.';
    END IF;
END;

-- Триггер на удаление заказа, запрещающий удаление после оплаты
CREATE TRIGGER trg_DeleteOrder_PaymentCheck
BEFORE DELETE ON Orders
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Payments WHERE OrderID = OLD.OrderID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя удалить заказ после оплаты.';
    END IF;
END;

-- Триггер на удаление услуги, имеющей необработанные заказы
CREATE TRIGGER trg_DeleteService_UnprocessedOrdersCheck
BEFORE DELETE ON Services
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM OrderServices WHERE ServiceID = OLD.ServiceID) THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя удалить услугу, используемую в необработанных заказах.';
    END IF;
END;

-- Триггер на удаление оплаты для завершенного заказа
CREATE TRIGGER trg_DeletePayment_CompletedOrderCheck
BEFORE DELETE ON Payments
FOR EACH ROW
BEGIN
    IF EXISTS (SELECT 1 FROM Orders WHERE OrderID = OLD.OrderID AND Status = 'Завершен') THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Нельзя удалить оплату для завершенного заказа.';
    END IF;
END;


-- Вставка данных в таблицу Клиенты
INSERT INTO Clients (ClientID, Name, ContactInfo, Address)
VALUES
	(1, 'Иван Иванов', 'ivan.ivanov@email.com', 'ул. Ленина, д. 1'),
    (2, 'Мария Петрова', 'maria.petrova@email.com', 'пр. Гагарина, д. 22'),
    (3, 'Екатерина Смирнова', 'ekaterina.smirnova@email.com', 'ул. Пролетарская, д. 10'),
    (4, 'Андрей Васнецов', 'andrey.vasnetsov@email.com', 'пер. Садовый, д. 5'),
    (5, 'Ольга Ковалева', 'olga.kovaleva@email.com', 'ул. Солнечная, д. 3'),
    (6, 'Павел Козлов', 'pavel.kozlov@email.com', 'пр. Победы, д. 15'),
    (7, 'Татьяна Никитина', 'tatyana.nikitina@email.com', 'ул. Мира, д. 7'),
    (8, 'Денис Захаров', 'denis.zakharov@email.com', 'пер. Цветочный, д. 2'),
    (9, 'Анастасия Полякова', 'anastasia.polyakova@email.com', 'ул. Зеленая, д. 14'),
    (10, 'Глеб Морозов', 'gleb.morozov@email.com', 'пр. Лесной, д. 23'),
    (11, 'Дмитрий Петров', 'dmitriy.petrov@email.com', 'пр. Солнечный, д. 8'),
    (12, 'Елена Иванова', 'elena.ivanova@email.com', 'ул. Цветочная, д. 12'),
    (13, 'Николай Сидоров', 'nikolay.sidorov@email.com', 'пер. Проходной, д. 3'),
    (14, 'Анна Козлова', 'anna.kozlova@email.com', 'ул. Заводская, д. 17'),
    (15, 'Игорь Морозов', 'igor.morozov@email.com', 'пр. Речной, д. 9'),
    (16, 'Светлана Захарова', 'svetlana.zakharova@email.com', 'ул. Парковая, д. 6'),
    (17, 'Артем Лебедев', 'artem.lebedev@email.com', 'пер. Красный, д. 21'),
    (18, 'Маргарита Ковалева', 'margarita.kovaleva@email.com', 'пр. Ленинградский, д. 14'),
    (19, 'Дарья Полякова', 'darya.polyakova@email.com', 'ул. Привольная, д. 5'),
    (20, 'Андрей Никитин', 'andrey.nikitin@email.com', 'ул. Садовая, д. 11');

-- Вставка данных в таблицу Сотрудники
INSERT INTO Employees (EmployeeID, Name, Position, ContactInfo)
VALUES
	(1, 'Алексей Смирнов', 'Уборщик', 'alexey.smirnov@email.com'),
    (2, 'Елена Кузнецова', 'Начальник отдела', 'elena.kuznetsova@email.com'),
    (3, 'Надежда Сидорова', 'Уборщица', 'nadezhda.sidorova@email.com'),
    (4, 'Игорь Кузьмин', 'Менеджер', 'igor.kuzmin@email.com'),
    (5, 'Алиса Романова', 'Бухгалтер', 'alisa.romanova@email.com'),
    (6, 'Максим Соколов', 'Специалист по клиентам', 'maxim.sokolov@email.com'),
    (7, 'Анна Шестакова', 'Уборщица', 'anna.shestakova@email.com'),
    (8, 'Сергей Попов', 'Начальник отдела', 'sergey.popov@email.com'),
    (9, 'Маргарита Лебедева', 'Менеджер по продажам', 'margarita.lebedeva@email.com'),
    (10, 'Илья Королев', 'Уборщик', 'ilya.korolev@email.com'),
    (11, 'Ольга Соколова', 'Уборщица', 'olga.sokolova@email.com'),
    (12, 'Владимир Попов', 'Начальник отдела', 'vladimir.popov@email.com'),
    (13, 'Тимур Шестаков', 'Уборщик', 'timur.shestakov@email.com'),
    (14, 'Анастасия Романова', 'Менеджер', 'anastasia.romanova@email.com'),
    (15, 'Дмитрий Лебедев', 'Бухгалтер', 'dmitriy.lebedev@email.com'),
    (16, 'София Кузьмина', 'Специалист по клиентам', 'sofia.kuzmina@email.com'),
    (17, 'Павел Шаров', 'Уборщик', 'pavel.sharov@email.com'),
    (18, 'Наталья Королева', 'Начальник отдела', 'natalya.koroleva@email.com'),
    (19, 'Артем Смирнов', 'Менеджер по продажам', 'artem.smirnov@email.com'),
    (20, 'Екатерина Васнецова', 'Уборщица', 'ekaterina.vasnetsova@email.com');
    
-- Вставка данных в таблицу Услуги
INSERT INTO Services (ServiceID, ServiceName, Description, Price)
VALUES
	(1, 'Основная уборка', 'Общая уборка помещения', 5000.00),
    (2, 'Мойка окон', 'Чистка и мойка окон', 2000.00),
    (3, 'Генеральная уборка', 'Обширная уборка помещения', 7000.00),
    (4, 'Уборка после ремонта', 'Уборка и вынос строительного мусора', 10000.00),
    (5, 'Уборка офисных помещений', 'Чистка офисных кабинетов и общих зон', 8000.00),
    (6, 'Мытье фасадов', 'Очистка и мытье фасадов зданий', 9000.00),
    (7, 'Уборка квартир', 'Уборка жилых помещений', 6000.00),
    (8, 'Очистка ковров', 'Химчистка и обработка ковров', 4000.00),
    (9, 'Мытье автомобилей', 'Мойка и уборка внутри автомобилей', 2500.00),
    (10, 'Уборка бассейнов', 'Очистка и обработка бассейнов', 5000.00),
    (11, 'Полировка мебели', 'Обработка мебели специальными средствами', 3000.00),
    (12, 'Мойка ковров', 'Чистка и мойка ковров различных типов', 2500.00),
    (13, 'Уборка снега', 'Удаление снега и посыпка соляной смесью', 3000.00),
    (14, 'Мытье фасадов стеклянных зданий', 'Очистка и мытье стеклянных поверхностей', 7000.00),
    (15, 'Химчистка мягкой мебели', 'Очистка тканевой мягкой мебели', 3500.00),
    (16, 'Мытье посуды', 'Мытье и полировка посуды в офисных помещениях', 2500.00),
    (17, 'Уборка специализированных помещений', 'Чистка помещений с использованием специального оборудования', 7000.00),
    (18, 'Мойка автотранспорта', 'Мойка кузова и салона автомобиля', 2000.00),
    (19, 'Чистка вентиляционных систем', 'Очистка и дезинфекция вентиляционных систем', 5500.00),
    (20, 'Уборка складских помещений', 'Обслуживание складов и складских помещений', 8000.00);    

-- Вставка данных в таблицу Заказы
INSERT INTO Orders (OrderID, ClientID, EmployeeID, Date, Status, TotalAmount, PaymentStatus)
VALUES
	(1, 1, 1, '2023-01-01', 'В процессе', 5000.00, 'Ожидает оплаты'),
    (2, 2, 2, '2023-02-01', 'Завершен', 2000.00, 'Оплачен'),
    (3, 3, 3, '2023-03-01', 'Ожидает выполнения', 7000.00, 'Не оплачен'),
    (4, 4, 4, '2023-04-01', 'В процессе', 10000.00, 'Ожидает оплаты'),
    (5, 5, 5, '2023-05-01', 'Завершен', 8000.00, 'Оплачен'),
    (6, 6, 6, '2023-06-01', 'В процессе', 9000.00, 'Ожидает оплаты'),
    (7, 7, 7, '2023-07-01', 'Завершен', 6000.00, 'Оплачен'),
    (8, 8, 8, '2023-08-01', 'В процессе', 4000.00, 'Ожидает оплаты'),
    (9, 9, 9, '2023-09-01', 'Ожидает выполнения', 2500.00, 'Не оплачен'),
    (10, 10, 10, '2023-10-01', 'Завершен', 5000.00, 'Оплачен'),
    (11, 11, 11, '2023-11-01', 'В процессе', 3000.00, 'Ожидает оплаты'),
    (12, 12, 12, '2023-12-01', 'Завершен', 2500.00, 'Оплачен'),
    (13, 13, 13, '2024-01-01', 'Ожидает выполнения', 3000.00, 'Не оплачен'),
    (14, 14, 14, '2024-02-01', 'В процессе', 7000.00, 'Ожидает оплаты'),
    (15, 15, 15, '2024-03-01', 'Завершен', 3500.00, 'Оплачен'),
    (16, 16, 16, '2024-04-01', 'В процессе', 2500.00, 'Ожидает оплаты'),
    (17, 17, 17, '2024-05-01', 'Завершен', 7000.00, 'Оплачен'),
    (18, 18, 18, '2024-06-01', 'В процессе', 2000.00, 'Ожидает оплаты'),
    (19, 19, 19, '2024-07-01', 'Ожидает выполнения', 5500.00, 'Не оплачен'),
    (20, 20, 20, '2024-08-01', 'Завершен', 8000.00, 'Оплачен');

-- Вставка данных в таблицу Услуги_в_заказе
INSERT INTO OrderServices (OrderID, ServiceID, Quantity)
VALUES
	(1, 1, 1),
    (1, 2, 2),
    (3, 3, 2),
    (3, 4, 1),
    (4, 5, 3),
    (4, 6, 1),
    (5, 7, 2),
    (5, 8, 1),
    (6, 9, 1),
    (6, 10, 2),
    (7, 3, 1),
    (7, 4, 2),
    (8, 5, 2),
    (8, 6, 1),
    (9, 7, 3),
    (9, 8, 2),
    (10, 9, 1),
    (10, 10, 3),
    (11, 11, 1),
    (11, 12, 2),
    (12, 13, 2),
    (12, 14, 1),
    (13, 15, 3),
    (13, 16, 1),
    (14, 17, 2),
    (14, 18, 1),
    (15, 19, 1),
    (15, 20, 2),
    (16, 11, 1),
    (16, 12, 2),
    (17, 13, 2),
    (17, 14, 1),
    (18, 15, 3),
    (18, 16, 2),
    (19, 17, 1),
    (19, 18, 3),
    (20, 19, 2),
    (20, 20, 1);

-- Вставка данных в таблицу Оплаты
INSERT INTO Payments (PaymentID, OrderID, Amount, PaymentDate)
VALUES
    (1, 1, 700.00, '2023-01-05'),
    (2, 2, 300.00, '2023-02-10'),
    (3, 3, 700.00, '2023-03-05'),
    (4, 4, 1000.00, '2023-04-10'),
    (5, 5, 800.00, '2023-05-15'),
    (6, 6, 1200.00, '2023-06-20'),
    (7, 7, 600.00, '2023-07-25'),
    (8, 8, 400.00, '2023-08-30'),
    (9, 9, 250.00, '2023-09-05'),
    (10, 10, 1500.00, '2023-10-10'),
    (11, 11, 500.00, '2023-11-05'),
    (12, 12, 200.00, '2023-12-10'),
    (13, 13, 400.00, '2024-01-05'),
    (14, 14, 800.00, '2024-02-10'),
    (15, 15, 600.00, '2024-03-15'),
    (16, 16, 1000.00, '2024-04-20'),
    (17, 17, 700.00, '2024-05-25'),
    (18, 18, 300.00, '2024-06-30'),
    (19, 19, 550.00, '2024-07-05'),
    (20, 20, 1200.00, '2024-08-10');

-- Вывод данных из таблицы Клиенты
SELECT * FROM Clients;

-- Вывод данных из таблицы Сотрудники
SELECT * FROM Employees;

-- Вывод данных из таблицы Услуги
SELECT * FROM Services;

-- Вывод данных из таблицы Заказы
SELECT * FROM Orders;

-- Вывод данных из таблицы Услуги в заказе
SELECT * FROM OrderServices;

-- Вывод данных из таблицы Оплаты
SELECT * FROM Payments;