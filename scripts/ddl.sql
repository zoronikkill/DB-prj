-- Таблица владельцев жилья
CREATE TABLE IF NOT EXISTS Owners (
    owner_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date TIMESTAMP NOT NULL
);

-- Таблица клиентов
CREATE TABLE IF NOT EXISTS Clients (
    client_id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date TIMESTAMP NOT NULL
);

-- Таблица недвижимости
CREATE TABLE IF NOT EXISTS Properties (
    property_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL REFERENCES Owners(owner_id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 3) NOT NULL,
    status TEXT CHECK (status IN ('available', 'unavailable'))
);

-- Таблица бронирований
CREATE TABLE IF NOT EXISTS Bookings (
    booking_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES Clients(client_id) ON DELETE CASCADE,
    property_id INT NOT NULL REFERENCES Properties(property_id) ON DELETE CASCADE,
    check_in_date DATE NOT NULL,
    check_out_date DATE NOT NULL,
    total_price NUMERIC(10, 3) NOT NULL,
    status TEXT CHECK (status IN ('pending', 'confirmed', 'cancelled'))
);

-- Таблица оплат
CREATE TABLE IF NOT EXISTS Payments (
    payment_id SERIAL PRIMARY KEY,
    booking_id INT NOT NULL REFERENCES Bookings(booking_id) ON DELETE CASCADE,
    amount NUMERIC(10, 3) NOT NULL,
    payment_date TIMESTAMP NOT NULL,
    payment_method TEXT CHECK (payment_method IN ('card', 'cash', 'bank_transfer')),
    status TEXT CHECK (status IN ('completed', 'pending', 'failed'))
);

-- Таблица отзывов
CREATE TABLE IF NOT EXISTS Reviews (
    review_id SERIAL PRIMARY KEY,
    client_id INT NOT NULL REFERENCES Clients(client_id) ON DELETE CASCADE,
    property_id INT NOT NULL REFERENCES Properties(property_id) ON DELETE CASCADE,
    rating NUMERIC(3, 2) CHECK (rating BETWEEN 1 AND 5),
    comment TEXT,
    review_date TIMESTAMP NOT NULL
);

-- Таблица истории изменений недвижимости
CREATE TABLE IF NOT EXISTS PropertiesHistory (
    history_id SERIAL PRIMARY KEY,
    property_id INT NOT NULL REFERENCES Properties(property_id) ON DELETE CASCADE,
    address TEXT NOT NULL,
    description TEXT,
    price NUMERIC(10, 3) NOT NULL,
    status TEXT CHECK (status IN ('available', 'unavailable')),
    valid_from TIMESTAMP NOT NULL,
    valid_to TIMESTAMP
);
