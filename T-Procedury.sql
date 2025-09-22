/*ClientHandler - usuwa klientów, których PESEL, imię lub nazwisko są puste. Dodatkowo analizuje liczbę roszczeń
w podanym roku. Jeśli klient złożył więcej niż 20 roszczeń i nie był wcześniej oznaczony jako podejrzany, jego status
zostaje zmieniony, a otwarte roszczenia trafiają do weryfikacji. Jeśli natomiast klient był już wcześniej oznaczony jako
podejrzany, wszystkie jego otwarte roszczenia są zamykane.*/

CREATE PROCEDURE ClientHandler
    @year INT
AS
BEGIN
    DECLARE
        @ClientName VARCHAR(20),
        @ClientSurname VARCHAR(20),
        @ClientPesel VARCHAR(11),
        @ClientClaimsCounter INT,
        @ClientStatus CHAR(1);

    DECLARE ClientCursor CURSOR FOR
        SELECT Imie, Nazwisko, Pesel FROM KLIENT;

    OPEN ClientCursor;
    FETCH NEXT FROM ClientCursor INTO @ClientName, @ClientSurname, @ClientPesel;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@ClientPesel IS NULL OR @ClientName IS NULL OR @ClientSurname IS NULL)
        BEGIN
            DELETE FROM Klient
            WHERE Pesel = @ClientPesel;

            PRINT 'Usunięto klienta: ' + ISNULL(@ClientName, '') + ' ' + ISNULL(@ClientSurname, '') + ' (PESEL: ' + ISNULL(@ClientPesel, 'NULL') + ')';
        END
        ELSE
        BEGIN
            SELECT @ClientClaimsCounter = COUNT(*)
            FROM Roszczenie
            WHERE Klient_Pesel = @ClientPesel
            AND YEAR(DataZdarzenia) = @year;

            SELECT @ClientStatus = Podejrzany
            FROM Klient
            WHERE Pesel = @ClientPesel;

            IF (@ClientClaimsCounter >= 20 AND @ClientStatus = 'n')
            BEGIN
                UPDATE Klient
                SET Podejrzany = 't'
                WHERE Pesel = @ClientPesel;

                UPDATE Roszczenie
                SET PracownikDecyzyjny_Id = 1, Status = 'WERYFIKACJA'
                WHERE Klient_Pesel = @ClientPesel AND Status = 'OTWARTE';

                PRINT 'Klient ' + @ClientPesel + ' oznaczony jako podejrzany.';
            END
            ELSE IF (@ClientClaimsCounter >= 20 AND @ClientStatus = 't')
            BEGIN
                UPDATE Roszczenie
                SET PracownikDecyzyjny_Id = 1, Status = 'ZAMKNIETE'
                WHERE Klient_Pesel = @ClientPesel AND Status = 'OTWARTE';

                PRINT 'Klient ' + @ClientPesel + ' uznany za oszusta. Roszczenia zamknięte.';
            END
        END

        FETCH NEXT FROM ClientCursor INTO @ClientName, @ClientSurname, @ClientPesel;
    END

    CLOSE ClientCursor;
    DEALLOCATE ClientCursor;
END

/*InsuranceTrashBag – procedura odpowiedzialna za usuwanie nieaktualnych lub pustych polis (bez ryzyk). Usuwane są polisy,
których data ważności upłynęła ponad 5 lat temu i które nie mają żadnych otwartych roszczeń. Dodatkowo usuwane są polisy, w
których nie wykupiono żadnego ryzyka. W przypadku polis, na które zgłoszono roszczenie z tytułu pożaru lub powodzi, data
ważności zostaje skrócona do kolejnego dnia od rejestracji takiego roszczenia. */

CREATE PROCEDURE InsuranceTrashBag
AS
    BEGIN
        DECLARE
            @InsuranceNum INT,
            @RiskCounter INT,
            @InsEndDate DATE,
            @ClaimStatus VARCHAR(20),
            @ClaimNumber INT,
            @FloFirCounter INT,
            @ClaimRegDate DATE;

        DECLARE InsuranceCursor CURSOR FOR SELECT NrPolisy FROM Polisa;
        OPEN InsuranceCursor;
        FETCH NEXT FROM InsuranceCursor INTO @InsuranceNum;
        WHILE @@FETCH_STATUS = 0
        BEGIN

            SELECT @RiskCounter = COUNT(*) FROM WarunkiUbezpieczenia
            WHERE Polisa_NrPolisy = @InsuranceNum;

            SELECT @InsEndDate = DataWaznosci FROM Polisa
            WHERE NrPolisy = @InsuranceNum;

            IF(@RiskCounter = 0) BEGIN
                DELETE FROM Polisa
                WHERE NrPolisy = @InsuranceNum
            end
            ELSE IF(DATEDIFF(YEAR, @InsEndDate, GETDATE()) >= 5) BEGIN
                IF NOT EXISTS (SELECT 1 FROM Roszczenie WHERE Polisa_NrPolisy = @InsuranceNum AND Status = 'OTWARTE')
                BEGIN
                    DELETE FROM Polisa WHERE NrPolisy = @InsuranceNum;
                END
            end

            SELECT TOP 1 @ClaimNumber = nrSzkody, @ClaimStatus = Status, @ClaimRegDate = DataRejestr FROM Roszczenie
            WHERE Polisa_NrPolisy = @InsuranceNum
            ORDER BY DataRejestr DESC;

            SELECT @FloFirCounter = COUNT(*) FROM Roszczenie
            WHERE Polisa_NrPolisy = @InsuranceNum AND
            (Ryzyko = 'Pozar' OR Ryzyko = 'Powodz');

            IF(@FloFirCounter != 0) BEGIN

                UPDATE Polisa
                SET DataWaznosci = DATEADD(DAY, 1, @ClaimRegDate);

            end
        end
        CLOSE InsuranceCursor;
        DEALLOCATE InsuranceCursor;
    end

/*ClientValidator - jeśli tworzony klient nie ma peselu wyświetli się błąd i jako pesel doda 11 jedynek. Jeśli użytkownik
bazy danych spróbuje usunąć klienta który ma aktywną polisę, lub roszczenie o statusie 'OTWARTE' wyświetli się błąd. Jeśli
status rekordu PODEJRZANY zostanie zmieniony na 't' to do jego otwartych roszczeń zostanie przypisany pracownik decyzyjny
o id 1. (FOR) Wyświetlone błędy nie wpłyną na wynik operacji (Oprócz przypadku aktywnych roszczeń). */

CREATE TRIGGER ClientValidator ON Klient
FOR INSERT, DELETE, UPDATE
AS
BEGIN

    IF EXISTS (SELECT 1 FROM inserted WHERE Pesel IS NULL)
    BEGIN
        PRINT 'Nie można dodać klienta bez PESELu. Nadano PESEL = 11111111111.';

        UPDATE Klient
        SET Pesel = '11111111111'
        WHERE Pesel IS NULL;
    end;

    IF EXISTS (SELECT 1 FROM deleted) AND NOT EXISTS (SELECT 1 FROM inserted)
    BEGIN
        DECLARE @SPesel VARCHAR(11);

        DECLARE deletedCursor CURSOR FOR
            SELECT Pesel FROM deleted;

        OPEN deletedCursor;
        FETCH NEXT FROM deletedCursor INTO @SPesel;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            IF EXISTS (
                SELECT 1 FROM Polisa
                WHERE Klient_Pesel = @SPesel AND DataWaznosci >= GETDATE()
            )
            BEGIN
                PRINT 'Usunięty klient o peselu: ' + @SPesel + ' miał aktywną polisę.';
            end;

            IF EXISTS (
                SELECT 1 FROM Roszczenie
                WHERE Klient_Pesel = @SPesel AND Status = 'OTWARTE'
            )
            BEGIN
                THROW 51002, 'Usunięto klienta, który miał aktywne roszczenia. Operacja zostaje cofnięta.', 1;
                ROLLBACK;
                RETURN;
            end;

            FETCH NEXT FROM deletedCursor INTO @SPesel;
        end;

        CLOSE deletedCursor;
        DEALLOCATE deletedCursor;
    end;

    IF EXISTS (SELECT 1 FROM inserted WHERE Podejrzany = 't')
    BEGIN
        DECLARE @PodejrzanyPesel VARCHAR(11);

        DECLARE suspiciousCursor CURSOR FOR
            SELECT Pesel FROM inserted WHERE Podejrzany = 't';

        OPEN suspiciousCursor;
        FETCH NEXT FROM suspiciousCursor INTO @PodejrzanyPesel;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            UPDATE Roszczenie
            SET PracownikDecyzyjny_Id = 1
            WHERE Status = 'OTWARTE' AND Klient_Pesel = @PodejrzanyPesel;

            PRINT 'Pracownik decyzyjny został przypisany do otwartych roszczeń klienta podejrzanego o PESEL: ' + @PodejrzanyPesel;

            FETCH NEXT FROM suspiciousCursor INTO @PodejrzanyPesel;
        end;

        CLOSE suspiciousCursor;
        DEALLOCATE suspiciousCursor;
    end;
end;

/*ClaimValidator - Po utworzeniu nowego roszczenia przez klienta podejrzanego o oszustwo do jego roszczenia przypisywany
jest pracownik o id 1. W przypadku roszczeń osób podejrzanych jeśli osoba decyzyjna zmieni status roszczenia na 'ZAMKNIĘTE'
to zanim to nastąpi trigger zmieni status na 'WERYFIKACJA', a jako osobę decyzyjną przypisze pracownika o id 2.*/

CREATE TRIGGER ClaimValidator ON Roszczenie
INSTEAD OF INSERT, UPDATE
AS
    BEGIN
        DECLARE
            @SPesel VARCHAR(11),
            @fishyStatus CHAR(1),
            @fishyClaimNumber INT,
            @fishyIncDate DATE,
            @fishyRegDate DATE,
            @fishyRisk VARCHAR(20),
            @fishyFileId INT,
            @fishyInsNum INT,
            @fishyEmpNum INT,
            @fishyDecEmpNum INT,
            @fishyClaimStatus VARCHAR(20);

        IF EXISTS(SELECT * FROM INSERTED) AND NOT EXISTS(SELECT * FROM DELETED) BEGIN
            SELECT @SPesel = Klient_Pesel FROM inserted;
            SELECT @fishyStatus = Podejrzany FROM Klient
            WHERE Pesel = @SPesel;

            SELECT nrSzkody = @fishyClaimNumber, DataZdarzenia = @fishyIncDate, DataRejestr = @fishyRegDate, Ryzyko = @fishyRisk,
            TeczkaSzkodowa_IdTeczki = @fishyFileId, Polisa_NrPolisy = @fishyInsNum, PracownikRejestr_Id = @fishyEmpNum,
            PracownikDecyzyjny_Id = @fishyDecEmpNum, Status = @fishyClaimStatus
            FROM inserted;

            IF(@fishyStatus = 't') BEGIN
                INSERT INTO ROSZCZENIE (nrSzkody, DataZdarzenia, DataRejestr, Ryzyko, Klient_Pesel, TeczkaSzkodowa_IdTeczki,
                                        Polisa_NrPolisy, PracownikRejestr_Id, PracownikDecyzyjny_Id, Status)
                VALUES (@fishyClaimNumber, @fishyIncDate, @fishyRegDate, @fishyRisk, @SPesel,
                        @fishyFileId,@fishyInsNum, @fishyEmpNum,1, @fishyClaimStatus);
            end
        end
        ELSE IF EXISTS(SELECT * FROM INSERTED) AND EXISTS(SELECT * FROM DELETED) BEGIN

            UPDATE r
        SET r.Status = 'WERYFIKACJA',
            r.PracownikDecyzyjny_Id = 2
        FROM Roszczenie r
        JOIN inserted i ON r.nrSzkody = i.nrSzkody
        JOIN Klient k ON i.Klient_Pesel = k.Pesel
        WHERE i.Status = 'ZAMKNIĘTE' AND k.Podejrzany = 't';

        end
    end