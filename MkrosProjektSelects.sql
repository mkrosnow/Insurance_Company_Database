/*Klienci z numerem telefonu zaczynającym się od '987'*/
SELECT * FROM Klient
WHERE NrTelefonu LIKE '987%';

/*Ulice, których kod pocztowy zaczyna się od '00'*/
SELECT Ulica FROM AdresKoresp
WHERE KodPocztowy LIKE '00%';

/* Roszczenia dotyczące 'Pożaru'*/
SELECT * FROM Roszczenie
WHERE Ryzyko = 'Pożar';

/*Polisy wygasające po dacie 2025-01-01*/
SELECT NrPolisy FROM Polisa
WHERE DataWaznosci > TO_DATE('2025-01-01', 'YYYY-MM-DD');

/* Teczki szkodowe, których nazwa firmy zaczyna się na 'Ment'*/
SELECT * FROM TeczkaSzkodowa
WHERE NazwaFirmaOględziny = 'Mentax';

//-------------------------------------------------------------------------Złączenia-------------------------------------------------------------------------------------

/*Lista klientów z ich adresami*/
SELECT K.Pesel, K.Imie, K.Nazwisko, A.Ulica, A.NrDomu, A.NrMieszkania, A.KodPocztowy
FROM Klient K
JOIN AdresKoresp A ON K.AdresKoresp_IdAdres = A.IdAdres;

/*Klienci i ich polisy*/
SELECT K.Imie, K.Nazwisko, P.NrPolisy, P.Typ
FROM Klient K
JOIN Polisa P ON K.Pesel = P.Klient_Pesel;

/*Roszczenia z informacjami o kliencie*/
SELECT R.nrSzkody, R.DataZdarzenia, R.Ryzyko, K.Imie, K.Nazwisko
FROM Roszczenie R
JOIN Klient K ON R.Klient_Pesel = K.Pesel;

/*Klienci, którzy mają polisy dotyczące ryzyka 'Pożar'*/
SELECT K.Imie, K.Nazwisko, P.NrPolisy, W.Ryzyko
FROM Klient K
JOIN Polisa P ON K.Pesel = P.Klient_Pesel
JOIN WarunkiUbezpieczenia W ON P.NrPolisy = W.Polisa_NrPolisy
WHERE W.Ryzyko = 'Pożar';

/*Dokumenty i ich szkodowe teczki  */
SELECT D.Barcode, D.DataWysylania, T.NazwaFirmaOględziny
FROM Dokument D
JOIN TeczkaSzkodowa T ON D.TeczkaSzkodowa_IdTeczki = T.IdTeczki;

//----------------------------------------------------------------------GROUP BY & HAVING--------------------------------------------------------------------------------

/*Liczba roszczeń dla każdego klienta*/
SELECT Klient.Nazwisko, Klient.Imie, COUNT(nrSzkody) AS LiczbaRoszczen
FROM Roszczenie
INNER JOIN Klient ON Roszczenie.Klient_Pesel = Klient.Pesel
GROUP BY Klient.Nazwisko, Klient.Imie;

/*Liczba roszczeń z różnych ryzyk*/
SELECT Ryzyko, COUNT(nrSzkody) AS LiczbaRoszczen
FROM Roszczenie
GROUP BY Ryzyko;

/*Liczba dokumentów wysłanych w danym dniu*/
SELECT DataWysylania, COUNT(Barcode) AS LiczbaDokumentow
FROM Dokument
GROUP BY DataWysylania;

/*Liczba roszczeń dla każdego klienta z warunkiem HAVING (ponad 1 roszczenie)*/
SELECT Klient_Pesel, COUNT(nrSzkody) AS LiczbaRoszczen
FROM Roszczenie
GROUP BY Klient_Pesel
HAVING COUNT(nrSzkody) > 1;

/*Liczba polis dla różnych typów, tylko te, które mają więcej niż 1 polisę*/
SELECT Typ, COUNT(NrPolisy) AS LiczbaPolis
FROM Polisa
GROUP BY Typ
HAVING COUNT(NrPolisy) > 1;

//-----------------------------------------------------------------------Podzapytania-------------------------------------------------------------

/*Klient, który ma najnowszą polisę*/
SELECT Imie, Naziwsko
FROM Klient 
WHERE Pesel = (SELECT Klient_Pesel 
               FROM Polisa 
               WHERE DataWaznosci = (SELECT MAX(DataWaznosci) FROM Polisa));
               
/*Roszczenia związane z polisami, które mają 'Powódź' jako ryzyko*/
SELECT * 
FROM Roszczenie 
WHERE Polisa_NrPolisy IN (SELECT NrPolisy 
                           FROM WarunkiUbezpieczenia 
                           WHERE Ryzyko = 'Powódź');
                           
/*Pracownicy, którzy zarejestrowali co najmniej jedno roszczenie*/
SELECT * 
FROM Pracownik 
WHERE Id IN (SELECT PracownikRejestr_Id 
             FROM Roszczenie);

/*Klienci, którzy mają polisę 'Majątkowa'Klienci, którzy mają polisę 'Majątkowa'*/
SELECT * 
FROM Klient 
WHERE Pesel IN (SELECT Klient_Pesel 
                FROM Polisa 
                WHERE Typ = 'Majątkowa');
                
/*Dokumenty wysłane po 2024-01-01 związane z teczkami o nazwie "Mentax"*/
SELECT * 
FROM Dokument 
WHERE TeczkaSzkodowa_IdTeczki IN (SELECT IdTeczki 
                                   FROM TeczkaSzkodowa 
                                   WHERE NazwaFirmaOględziny = 'Mentax')
AND DataWysylania > TO_DATE('2024-01-01', 'YYYY-MM-DD');
