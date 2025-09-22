DROP TABLE IF EXISTS DOKUMENT;
DROP TABLE IF EXISTS ROSZCZENIE;
DROP TABLE IF EXISTS TECZKASZKODOWA;
DROP TABLE IF EXISTS PRACOWNIK;
DROP TABLE IF EXISTS NIERUCHOMOSC;
DROP TABLE IF EXISTS WARUNKIUBEZPIECZENIA;
DROP TABLE IF EXISTS POLISA;
DROP TABLE IF EXISTS KLIENT;
DROP TABLE IF EXISTS ADRESKORESP;
DROP TABLE IF EXISTS RYZYKO;



CREATE TABLE Ryzyko (
    IdRyzyko INT PRIMARY KEY,
    Opis VARCHAR(50)
);

CREATE TABLE AdresKoresp (
    IdAdres INT PRIMARY KEY,
    Ulica VARCHAR(20),
    NrDomu INT,
    NrMieszkania INT,
    KodPocztowy VARCHAR(6),
    email VARCHAR(30)
);

CREATE TABLE Klient (
    Pesel VARCHAR(11) PRIMARY KEY,
    Imie VARCHAR(20),
    Nazwisko VARCHAR(20),
    NrTelefonu INT,
    AdresKoresp_IdAdres INT,
    Podejrzany CHAR(1),
    FOREIGN KEY (AdresKoresp_IdAdres) REFERENCES AdresKoresp(IdAdres)
);

CREATE TABLE Polisa (
    NrPolisy INT PRIMARY KEY,
    Typ VARCHAR(20),
    DataWaznosci DATE,
    DataZalozenia DATE,
    Klient_Pesel VARCHAR(11),
    FOREIGN KEY (Klient_Pesel) REFERENCES Klient(Pesel)
);

CREATE TABLE WarunkiUbezpieczenia (
    Polisa_NrPolisy INT,
    Ryzyko_IdRyzyko INT,
    PRIMARY KEY (Polisa_NrPolisy, Ryzyko_IdRyzyko),
    FOREIGN KEY (Polisa_NrPolisy) REFERENCES Polisa(NrPolisy),
    FOREIGN KEY (Ryzyko_IdRyzyko) REFERENCES Ryzyko(IdRyzyko)
);

CREATE TABLE Nieruchomosc (
    Ulica VARCHAR(20),
    NrDomu INT,
    NrMieszkania INT,
    KodPocztowy VARCHAR(6),
    Polisa_NrPolisy INT,
    Klient_Pesel VARCHAR(11),
    PRIMARY KEY (Ulica, NrDomu, NrMieszkania, KodPocztowy),
    FOREIGN KEY (Polisa_NrPolisy) REFERENCES Polisa(NrPolisy),
    FOREIGN KEY (Klient_Pesel) REFERENCES Klient(Pesel)
);

CREATE TABLE Pracownik (
    Id INT PRIMARY KEY,
    Imie VARCHAR(20),
    Nazwisko VARCHAR(20)
);

CREATE TABLE TeczkaSzkodowa (
    IdTeczki INT PRIMARY KEY,
    NazwaFirmaOględziny VARCHAR(20),
    NrRachunku VARCHAR(20)
);

CREATE TABLE Roszczenie (
    nrSzkody INT PRIMARY KEY,
    DataZdarzenia DATE,
    DataRejestr DATE,
    Ryzyko VARCHAR(20),
    Klient_Pesel VARCHAR(11),
    TeczkaSzkodowa_IdTeczki INT,
    Polisa_NrPolisy INT,
    PracownikRejestr_Id INT,
    PracownikDecyzyjny_Id INT,
    Status VARCHAR(20),
    FOREIGN KEY (Klient_Pesel) REFERENCES Klient(Pesel),
    FOREIGN KEY (TeczkaSzkodowa_IdTeczki) REFERENCES TeczkaSzkodowa(IdTeczki),
    FOREIGN KEY (Polisa_NrPolisy) REFERENCES Polisa(NrPolisy),
    FOREIGN KEY (PracownikRejestr_Id) REFERENCES Pracownik(Id),
    FOREIGN KEY (PracownikDecyzyjny_Id) REFERENCES Pracownik(Id)
);

CREATE TABLE Dokument (
    IdDokumentu INT PRIMARY KEY,
    DataWysylania DATE,
    Barcode VARCHAR(20),
    TeczkaSzkodowa_IdTeczki INT,
    FOREIGN KEY (TeczkaSzkodowa_IdTeczki) REFERENCES TeczkaSzkodowa(IdTeczki)
);


-- Ryzyko
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (1, 'Pozar');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (2, 'Powodz');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (3, 'Kradziez');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (4, 'Upadek drzew i masztow');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (5, 'Przepiecie');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (6, 'Zalanie');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (7, 'Pekanie na skutek mrozu');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (8, 'Uderzenie pioruna');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (9, 'Uderzenie pojazdu mechanicznego');
INSERT INTO Ryzyko (IdRyzyko, Opis) VALUES (10, 'Upadek statku powietrznego');


-- AdresKoresp
INSERT INTO AdresKoresp (IdAdres, Ulica, NrDomu, NrMieszkania, KodPocztowy, email)
VALUES (1, 'Słoneczna', 10, 2, '00-123', 'jan.kowalski@outlook.com');
INSERT INTO AdresKoresp (IdAdres, Ulica, NrDomu, NrMieszkania, KodPocztowy, email)
VALUES (2, 'Krótka', 5, 1, '01-456', 'anna.nowak@gmail.com');
INSERT INTO AdresKoresp (IdAdres, Ulica, NrDomu, NrMieszkania, KodPocztowy, email)
VALUES (3, 'Wielka', 3, 4, '02-789', 'piotr.kaczmarek@hotmail.com');
INSERT INTO AdresKoresp (IdAdres, Ulica, NrDomu, NrMieszkania, KodPocztowy, email)
VALUES (4, 'Nowa', 12, 1, '03-101', 'marta.wisniewska@yahoo.com');

-- Klient
INSERT INTO Klient (Pesel, Imie, Nazwisko, NrTelefonu, AdresKoresp_IdAdres, Podejrzany)
VALUES ('12345678901', 'Jan', 'Kowalski', 123456789, 1, 'N');
INSERT INTO Klient (Pesel, Imie, Nazwisko, NrTelefonu, AdresKoresp_IdAdres, Podejrzany)
VALUES ('98765432109', 'Anna', 'Nowak', 987654321, 2, 'N');
INSERT INTO Klient (Pesel, Imie, Nazwisko, NrTelefonu, AdresKoresp_IdAdres, Podejrzany)
VALUES ('23456789012', 'Piotr', 'Kaczmarek', 234567890, 3, 'N');
INSERT INTO Klient (Pesel, Imie, Nazwisko, NrTelefonu, AdresKoresp_IdAdres, Podejrzany)
VALUES ('34567890123', 'Marta', 'Wiśniewska', 345678901, 4, 'N');
INSERT INTO Klient (Pesel, Imie, Nazwisko, NrTelefonu, AdresKoresp_IdAdres, Podejrzany)
VALUES(null, 'Bogdan', 'Rymanowicz', null, null, 'n');

-- Polisa
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1001, 'Majatkowa', ('2026-12-31'), ('2025-01-01'), '12345678901');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1002, 'Majatkowa', ('2028-11-21'), ('2022-11-20'), '12345678901');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1003, 'Majatkowa', ('2023-06-12'), ('2021-06-11'), '98765432109');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1004, 'Majatkowa', ('2028-12-04'), ('2024-12-03'), '98765432109');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1005, 'Majatkowa', ('2025-07-08'), ('2025-04-10'), '23456789012');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1006, 'Majatkowa', ('2026-07-31'), ('2024-08-01'), '34567890123');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1007, 'Majatkowa', ('2027-08-09'), ('2012-08-10'), '12345678901');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1008, 'Majatkowa', ('2021-12-21'), ('2020-12-22'), '12345678901');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1009, 'Majatkowa', ('2021-12-22'), ('2020-12-23'), '12345678901');
INSERT INTO Polisa (NrPolisy, Typ, DataWaznosci, DataZalozenia, Klient_Pesel) VALUES (1010, 'Majatkowa', ('2026-12-31'), ('2025-01-01'), '34567890123');


-- WarunkiUbezpieczenia
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1001, 1);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1001, 3);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1001, 5);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1001, 10);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1002, 2);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1002, 4);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1002, 6);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1002, 8);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1003, 3);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1004, 4);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1004, 8);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1004, 10);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1005, 1);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1005, 2);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1005, 3);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1005, 5);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1005, 6);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1006, 2);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1006, 3);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1006, 4);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1006, 7);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1006, 8);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1007, 1);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1007, 8);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1007, 9);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1007, 10);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1008, 1);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1008, 2);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1008, 3);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1008, 4);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1008, 5);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1009, 1);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1009, 2);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1009, 9);
INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1009, 10);

INSERT INTO WarunkiUbezpieczenia (Polisa_NrPolisy, Ryzyko_IdRyzyko)
VALUES (1010, 10);


-- Nieruchomosc
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Słoneczna', 10, 2, '00-123', 1001, '12345678901');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Krótka', 5, 1, '01-456', 1002, '12345678901');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Zielona', 8, 1, '02-556', 1003, '98765432109');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Niska', 10, 2, '03-466', 1004, '98765432109');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Ratuszowa', 8, 10, '46-286', 1005, '23456789012');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Słoneczna', 2, 0, '76-260', 1006, '34567890123');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Francuska', 10, 2, '06-888', 1007, '12345678901');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Owocowa', 65, 34, '08-952', 1008, '12345678901');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Skłodowskiej Curie', 23, 1, '56-218', 1009, '12345678901');
INSERT INTO Nieruchomosc (Ulica, NrDomu, NrMieszkania, KodPocztowy, Polisa_NrPolisy, Klient_Pesel) VALUES ('Angielska', 14, 2, '06-254', 1010, '34567890123');

-- Pracownik
INSERT INTO Pracownik (Id, Imie, Nazwisko)
VALUES (1, 'Tomasz', 'Wójcik');
INSERT INTO Pracownik (Id, Imie, Nazwisko)
VALUES (2, 'Maria', 'Zielińska');
INSERT INTO Pracownik (Id, Imie, Nazwisko)
VALUES (3, 'Krzysztof', 'Nowak');
INSERT INTO Pracownik (Id, Imie, Nazwisko)
VALUES (4, 'Monika', 'Kowalska');

-- TeczkaSzkodowa
INSERT INTO TeczkaSzkodowa (IdTeczki, NazwaFirmaOględziny, NrRachunku) VALUES (1, 'Mentax', '12345-67890');
INSERT INTO TeczkaSzkodowa (IdTeczki, NazwaFirmaOględziny, NrRachunku) VALUES (2, 'Kama24', '98765-43210');
INSERT INTO TeczkaSzkodowa (IdTeczki, NazwaFirmaOględziny, NrRachunku) VALUES (3, 'Kama24', '68425-11112');
INSERT INTO TeczkaSzkodowa (IdTeczki, NazwaFirmaOględziny, NrRachunku) VALUES (4, 'RTS', '92435-10000');

-- Roszczenie
INSERT INTO Roszczenie (nrSzkody, DataZdarzenia, DataRejestr, Ryzyko, Klient_Pesel, TeczkaSzkodowa_IdTeczki, Polisa_NrPolisy, PracownikRejestr_Id, PracownikDecyzyjny_Id, Status)
VALUES (1, ('2024-01-01'), ('2024-01-02'), 'Pozar', '12345678901', 1, 1001, 1, 2, 'OTWARTE');
INSERT INTO Roszczenie (nrSzkody, DataZdarzenia, DataRejestr, Ryzyko, Klient_Pesel, TeczkaSzkodowa_IdTeczki, Polisa_NrPolisy, PracownikRejestr_Id, PracownikDecyzyjny_Id, Status)
VALUES (2, ('2024-02-15'), ('2024-02-16'), 'Kradziez', '98765432109', 2, 1002, 2, 1, 'ZAAKCEPTOWANE');
INSERT INTO Roszczenie (nrSzkody, DataZdarzenia, DataRejestr, Ryzyko, Klient_Pesel, TeczkaSzkodowa_IdTeczki, Polisa_NrPolisy, PracownikRejestr_Id, PracownikDecyzyjny_Id, Status)
VALUES (3, ('2024-03-01'), ('2024-03-02'), 'Przepiecie', '23456789012', 3, 1003, 3, 4, 'ZAMKNIETE');
INSERT INTO Roszczenie (nrSzkody, DataZdarzenia, DataRejestr, Ryzyko, Klient_Pesel, TeczkaSzkodowa_IdTeczki, Polisa_NrPolisy, PracownikRejestr_Id, PracownikDecyzyjny_Id, Status)
VALUES (4, ('2025-01-12'), ('2025-01-14'), 'Zalanie', '34567890123', 4, 1010, 3, 4, 'OTWARTE');

-- Dokument
INSERT INTO Dokument (IdDokumentu ,DataWysylania, Barcode, TeczkaSzkodowa_IdTeczki)
VALUES (1 ,('2024-01-03'), 'DOC10001', 1);
INSERT INTO Dokument (IdDokumentu ,DataWysylania, Barcode, TeczkaSzkodowa_IdTeczki)
VALUES (2, ('2024-02-17'), 'DOC10002', 2);
INSERT INTO Dokument (IdDokumentu ,DataWysylania, Barcode, TeczkaSzkodowa_IdTeczki)
VALUES (3, ('2024-03-05'), 'DOC10003', 3);
INSERT INTO Dokument (IdDokumentu ,DataWysylania, Barcode, TeczkaSzkodowa_IdTeczki)
VALUES (4, ('2025-01-23'), 'DOC10004', 4);

