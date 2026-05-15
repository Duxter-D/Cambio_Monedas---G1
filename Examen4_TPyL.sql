DO $$
DECLARE
    v_monedas   TEXT[]  := ARRAY['Dólar estadounidense', 'Euro', 'Libra esterlina', 'Yen japonés'];
    v_siglas    TEXT[]  := ARRAY['USD', 'EUR', 'GBP', 'JPY'];
    v_simbolos  TEXT[]  := ARRAY['$', '€', '£', '¥'];
    v_emisores  TEXT[]  := ARRAY['Reserva Federal de EE.UU.', 'Banco Central Europeo', 'Banco de Inglaterra', 'Banco de Japón'];
    v_cambios_base FLOAT[] := ARRAY[4200.0, 4600.0, 5300.0, 28.0];
    v_fecha         DATE;
    v_fecha_inicio  DATE := CURRENT_DATE - INTERVAL '2 months';
    v_fecha_fin     DATE := CURRENT_DATE;
    v_id_moneda     INT;
    v_cambio        FLOAT;
    i               INT;
BEGIN
    FOR i IN 1..4 LOOP

        SELECT Id INTO v_id_moneda
        FROM moneda WHERE Sigla = v_siglas[i];

        IF NOT FOUND THEN
            INSERT INTO moneda (Moneda, Sigla, Simbolo, Emisor)
            VALUES (v_monedas[i], v_siglas[i], v_simbolos[i], v_emisores[i])
            RETURNING Id INTO v_id_moneda;
        END IF;

        v_fecha := v_fecha_inicio;

        WHILE v_fecha <= v_fecha_fin LOOP

            v_cambio := ROUND((v_cambios_base[i] * (1 + (RANDOM() * 0.04 - 0.02)))::NUMERIC, 2);

            IF EXISTS (SELECT 1 FROM cambiomoneda WHERE IdMoneda = v_id_moneda AND Fecha::DATE = v_fecha) THEN
                UPDATE cambiomoneda SET Cambio = v_cambio
                WHERE IdMoneda = v_id_moneda AND Fecha::DATE = v_fecha;
            ELSE
                INSERT INTO cambiomoneda (IdMoneda, Fecha, Cambio)
                VALUES (v_id_moneda, v_fecha, v_cambio);
            END IF;

            v_fecha := v_fecha + INTERVAL '1 day';
        END LOOP;

    END LOOP;
END;
$$;