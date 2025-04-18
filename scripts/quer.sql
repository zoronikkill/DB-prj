-- 1. Выбор доступных объектов недвижимости с ценой ниже заданного значения
SELECT p.property_id,
       p.address,
       p.price
FROM Properties p
WHERE p.status = 'available'
  AND p.price < 150.00
ORDER BY p.price ASC;

-- 2. Рейтинг объектов по количеству бронирований
SELECT
    property_id,
    address,
    COUNT(booking_id) AS bookings_count,
    RANK() OVER (ORDER BY COUNT(booking_id) DESC) AS rank
FROM Properties
LEFT JOIN Bookings USING (property_id)
GROUP BY property_id;

-- 3. Вычисление средней оценки объектов недвижимости
SELECT p.property_id,
       p.address,
       ROUND(AVG(r.rating), 2) AS average_rating
FROM Properties p
JOIN Reviews r ON p.property_id = r.property_id
GROUP BY p.property_id, p.address
HAVING AVG(r.rating) > 4.0
ORDER BY average_rating DESC;

-- 4. Нахождение клиентов, которые бронировали больше определенного значения
SELECT client_id, name
FROM Clients
WHERE client_id IN (
    SELECT client_id
    FROM Bookings
    GROUP BY client_id
    HAVING COUNT(booking_id) > 1
)
ORDER BY name;

-- 5. Владелец с объектами, цена аренды которых выше среднего по рынку
SELECT o.owner_id,
       o.name,
       ROUND(AVG(pr.price), 2) AS avg_price
FROM Owners o
JOIN Properties pr ON o.owner_id = pr.owner_id
GROUP BY o.owner_id, o.name
HAVING AVG(pr.price) > (SELECT AVG(price) FROM Properties)
ORDER BY avg_price DESC;

-- 6. Объединение данных бронирований с информацией о клиентах и недвижимости
SELECT b.booking_id,
       c.name AS client_name,
       p.address AS property_address,
       b.check_in_date,
       b.check_out_date,
       b.total_price
FROM Bookings b
INNER JOIN Clients c ON b.client_id = c.client_id
INNER JOIN Properties p ON b.property_id = p.property_id;

-- 7. Недвижимость, которая имеет отзывы ниже определенного значения
SELECT DISTINCT p.property_id, p.address, r.rating
FROM Properties p
JOIN Reviews r ON p.property_id = r.property_id
WHERE r.rating < 4;

-- 8. Вывод того, какие клиенты на какую недвижимость какой отзыв давали
SELECT c.client_id,
       c.name,
       r.review_id,
       r.rating,
       r.review_date
FROM Clients c
FULL JOIN Reviews r ON c.client_id = r.client_id
ORDER BY c.client_id;

-- 9. Средняя продолжительность бронирования по каждому объекту
SELECT p.property_id,
       p.address,
       ROUND(AVG(b.check_out_date - b.check_in_date), 0) AS avg_duration_days
FROM Properties p
JOIN Bookings b ON p.property_id = b.property_id
GROUP BY p.property_id, p.address
ORDER BY avg_duration_days DESC;

-- 10. Изменение цен у недвижимостей
SELECT property_id,
       TO_CHAR(valid_from, 'YYYY-MM-DD') AS change_date,
       old_price,
       changed_price,
       ROUND(((changed_price - old_price) / NULLIF(old_price, 0)) * 100, 2) AS change_percent
FROM (
    SELECT property_id,
           valid_from,
           price AS changed_price,
           LAG(price) OVER (PARTITION BY property_id ORDER BY valid_from) AS old_price
    FROM PropertiesHistory
) AS sub
WHERE old_price IS NOT NULL
ORDER BY property_id, valid_from;

-- 11. Вторая страница топ-10 самых дорогих объектов с их рейтингом
SELECT 
    p.property_id,
    p.address,
    p.price,
    ROUND(AVG(r.rating) OVER (PARTITION BY p.property_id), 2) AS avg_rating
FROM Properties p
LEFT JOIN Reviews r ON p.property_id = r.property_id
ORDER BY p.price DESC
LIMIT 10 OFFSET 10;

-- 12 Владельцы с объектами, которые бронировались, но никогда не отменялись
SELECT DISTINCT
    o.owner_id,
    o.name AS owner_name,
    p.address
FROM Bookings b
RIGHT JOIN
    Properties p ON b.property_id = p.property_id
JOIN
    Owners o ON p.owner_id = o.owner_id
WHERE
    EXISTS (
        SELECT 1
        FROM Bookings b2
        WHERE b2.property_id = p.property_id
    )
    AND NOT EXISTS (
        SELECT 1
        FROM Bookings b3
        WHERE b3.property_id = p.property_id
          AND b3.status = 'cancelled'
    )
ORDER BY o.owner_id;

-- 13 Поиск объектов с одинаковой ценой
SELECT a.property_id, a.address, b.property_id, b.address, a.price
FROM Properties a
JOIN Properties b ON a.price = b.price 
WHERE a.property_id < b.property_id;
