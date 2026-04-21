-- 1.	Определить регионы с наибольшим количеством зарегистрированных доноров.
SELECT region,
	   count(id) AS amount_users
FROM donorsearch.user_anon_data
GROUP BY region
ORDER BY amount_users DESC;
  
--|region|amount_users|
--|------|------------|
--||100574|
--|Россия, Москва|37819|
--|Россия, Санкт-Петербург|13137|
--|Россия, Татарстан, Казань|6610|
--|Украина, Киевская область, Киев|3541|
--|Россия, Новосибирская область, Новосибирск|3310|
--|Россия, Свердловская область, Екатеринбург|3082|
--|Россия, Башкортостан, Уфа|3014|
--|Россия, Красноярский край, Красноярск|2346|
--|Россия, Краснодарский край, Краснодар|2186|

-- Вывод:
-- Топ-10 регионов с наибольшим количеством зарегистрированных доноров: Москва (кол-во доноров: 37 819), Санкт-Петербург (кол-во доноров: 13 137),
-- Казань (кол-во доноров: 6 610), Киев (кол-во доноров: 3 541), Новосибирск (кол-во доноров: 3 310), Екатеринбург (кол-во доноров: 3 082),
-- Уфа (кол-во доноров: 3 014), Красноярск (кол-во доноров: 2 346), Краснодар (кол-во доноров: 2 186), Ростов-на-Дону (кол-во доноров: 1 976).
--Практически во всех городах кол-во зарегистрированных доноров от общего населения составляет примерно 0,2%, в то время как в г. Казань 
--показатель чуть выше – 0,5%, в г. Москва и г. Уфа – 0,3%. Также, стоит отметить, что у 100 574 пользователей не указан регион, 
--примерно у половины пользователей отсутствует данная информация.


-- 2. Изучить динамику общего количества донаций в месяц за 2022 и 2023 годы.
SELECT EXTRACT(MONTH FROM donation_date) AS month,
	   count(donation_date) AS amount_donation
FROM donorsearch.donation_anon
WHERE donation_date BETWEEN '2022-01-01' AND '2022-12-31'
GROUP BY month
ORDER BY month;
--|month|amount_donation|
--|-----|---------------|
--|1    |1 977          |
--|2    |2 109          |
--|3    |3 002          |
--|4    |3 223          |
--|5    |2 414          |
--|6    |2 792          |
--|7    |2 836          |
--|8    |2 987          |
--|9    |3 089          |
--|10   |3 265          |
--|11   |3 156          |
--|12   |3 303          |

--Вывод:
--На протяжении 2022 года кол-во доноров в месяц варьируется от 1 977 до 3 303. Самое большое кол-во донаций в декабре – 3 303. Можно отметить, 
--что самым активным сезоном донорства является осень, сентябрь – 3 089, октябрь 3 265, ноябрь – 3 089. Менее активный сезон весна, 
--но также в апреле зафиксировано хорошее число донаций – 3 223. Умеренно активным сезоном можно считать лето, здесь кол-во донаций в диапазоне 2 792 
--до 2 987. Самый неактивный сезон зима, исключив декабрь. В январе 1 977 донаций, в феврале 2 109 донаций.
--Всего донаций за 2022 год – 34 153.

SELECT EXTRACT(MONTH FROM donation_date) AS month,
	   count(donation_date) AS amount_donation
FROM donorsearch.donation_anon
WHERE donation_date BETWEEN '2023-01-01' AND '2023-12-31'
GROUP BY month
ORDER BY month;

--|month|amount_donation|
--|-----|---------------|
--|1    |2 795          |
--|2    |3 056          |
--|3    |3 523          |
--|4    |2 951          |
--|5    |2 568          |
--|6    |2 651          |
--|7    |2 276          |
--|8    |2 433          |
--|9    |2 240          |
--|10   |2 117          |
--|11   |1 509          |

--Вывод:
--В 2023 году самые активные месяцы по донациям март – 3 523, февраль – 3 056, апрель 2 951. Умеренно активные январь – 2 795, 
--июнь - 2 651, май – 2 568, август – 2 433. Менее активные июль – 2 276, сентябрь – 2 240, октябрь – 2 117, ноябрь – 1509. 
--Можно отметить, что в 2023 года сезон неактивных донаций – осень. Также, отсутствуют данные за декабрь.
--Всего донаций за 2023 год – 28 119.

-- 3.	Определить наиболее активных доноров в системе, учитывая только данные о зарегистрированных и подтвержденных донациях.

SELECT id AS user,
	   confirmed_donations 
FROM donorsearch.user_anon_data
ORDER BY confirmed_donations DESC
LIMIT 10;

--|user   |confirmed_donations|
--|-------|-------------------|
--|235 391|361                |
--|273 317|257                |
--|201 521|236                |
--|211 970|236                |
--|132 946|227                |
--|53 912 |217                |
--|216 353|216                |
--|233 686|215                |
--|204 073|213                |
--|267 054|209                |

--Вывод: Топ 3 доноров по кол-ву подтвержденных донаций:
--1.	Донор 235391 – 361 донация;
--2.	Донор 273317 – 257 донаций;
--3.	Донор 201521 и 211970 – 236 донаций. 


--4.	Оценить, как система бонусов влияет на зарегистрированные в системе донации.

WITH donor_activity AS
  (SELECT u.id,
          u.confirmed_donations,
          COALESCE(b.user_bonus_count, 0) AS user_bonus_count
   FROM donorsearch.user_anon_data u
   LEFT JOIN donorsearch.user_anon_bonus b ON u.id = b.user_id)
SELECT CASE
           WHEN user_bonus_count > 0 THEN 'Получили бонусы'
           ELSE 'Не получали бонусы'
       END AS status,
       COUNT(id) AS amount_donors,
       AVG(confirmed_donations) AS avg_donations
FROM donor_activity
GROUP BY status;

--|status            |amount_donors|avg_donations|
--|------------------|-------------|-------------|
--|Не получали бонусы|256 491      |0,5250359662 |
--|Получили бонусы   |21 108       |13,9017907902|

-- Доноры, которые получили бонусы, в среднем делают значительно больше донаций (~13.90), чем те, кто не получил бонусы (~0.53).
-- Это свидетельствует о сильном положительном влиянии программ лояльности на активность доноров.

--5.	Исследовать вовлечение новых доноров через социальные сети. Узнать, сколько по каким каналам пришло доноров, и среднее количество донаций по каждому каналу.


WITH user_channels AS (
    SELECT id, registration_date, confirmed_donations, 'VK' AS channel
    FROM donorsearch.user_anon_data
    WHERE autho_vk = TRUE
    UNION ALL    
    SELECT id, registration_date, confirmed_donations, 'OK' AS channel
    FROM donorsearch.user_anon_data
    WHERE autho_ok = TRUE    
    UNION ALL    
    SELECT id, registration_date, confirmed_donations, 'Telegram' AS channel
    FROM donorsearch.user_anon_data
    WHERE autho_tg = TRUE    
    UNION ALL    
    SELECT id, registration_date, confirmed_donations, 'Yandex' AS channel
    FROM donorsearch.user_anon_data
    WHERE autho_yandex = TRUE    
    UNION ALL   
    SELECT id, registration_date, confirmed_donations, 'Google' AS channel
    FROM donorsearch.user_anon_data
    WHERE autho_google = TRUE   
    UNION ALL   
    SELECT id, registration_date, confirmed_donations, 'Direct/Other' AS channel
    FROM donorsearch.user_anon_data
    WHERE autho_vk = FALSE AND autho_ok = FALSE AND autho_tg = FALSE 
      AND autho_yandex = FALSE AND autho_google = FALSE
)
SELECT 
    channel,
    COUNT(id) AS amount_users,
    ROUND(AVG(confirmed_donations), 2) AS avg_donations
FROM user_channels
GROUP BY channel
ORDER BY amount_users DESC;

--|channel     |amount_users|avg_donations|
--|------------|------------|-------------|
--|VK          |127 254     |0,91         |
--|Direct/Other|113 266     |0,71         |
--|Google      |16 485      |2,22         |
--|OK          |7 766       |1,72         |
--|Yandex      |5 170       |3,9          |
--|Telegram    |890         |4,32         |

--В исследуемых данных нет явного указания канала привлечения пользователей, к тому же у каждого пользователя кол-во указанных каналов 
--варьируется от 0 до 5. Вычисляем сколько пользователей привязаны к тому или иному каналу и какое у них среднее кол-во донаций. 
--По результатам видно, что большинство пользователей привязали аккаунт к VK – 127 254 пол-лей, 
--но у них среднее число донаций самое минимальное – 0.91. У большинства пол-лей не указано никаких соц-сетей – 113 266. 
--Минимальное число пол-лей в Telegram, но они показывают максимальное среднее число донаций – 4.32.

--6.	Сравнить активность однократных доноров со средней активностью повторных доноров.

WITH donor_activity AS (
		SELECT user_id,
			   COUNT(*) AS total_donations,
			   (MAX(donation_date) - MIN(donation_date)) AS duration_between_donation,
			   EXTRACT(YEAR FROM MIN(donation_date)) AS first_donation,
			   (MAX(donation_date) - MIN(donation_date)) / (COUNT(*) - 1) AS avg_days_between_donations,
			   EXTRACT(YEAR FROM AGE(CURRENT_DATE, MIN(donation_date))) AS years_since_first_donation
	    FROM donorsearch.donation_anon
	    GROUP BY user_id
  	    HAVING COUNT(*) > 1
)
SELECT first_donation,
       CASE 
           WHEN total_donations BETWEEN 2 AND 3 THEN '2-3 донации'
           WHEN total_donations BETWEEN 4 AND 5 THEN '4-5 донаций'
           ELSE '6 и более донаций'
       END AS donation_frequency_group,
       COUNT(user_id) AS donor_count,
       AVG(total_donations) AS avg_donations_per_donor,
       AVG(duration_between_donation) AS avg_activity_duration_days,
       AVG(avg_days_between_donations) AS avg_days_between_donations,
       AVG(years_since_first_donation) AS avg_years_since_first_donation
FROM donor_activity
GROUP BY first_donation, donation_frequency_group
ORDER BY first_donation, donation_frequency_group;

--В данных обнаружены аномалии такие как длительные периоды активности доноров (около 1800 лет) и большие промежутки между донациями 
--(110 тыс. дней, 26 тыс. дней). Это свидетельствует о некорректности данных, особенно в части указания дат донаций, следовательно, анализ неинформативен, 
--требуется очистка данных.
--Несмотря на аномалии, можно предположить, что повторные доноры демонстрируют большую вовлечённость и остаются активными в течение длительного времени.
--Следовательно, после очистки стоит снова перепроверить вывод о том, что повторные доноры демонстрируют большую вовлеченность.


--7.	Сравнить данные о планируемых донациях с фактическими данными, чтобы оценить эффективность планирования.

WITH planned_donations AS (
    SELECT user_id,
           donation_date,
           donation_type,
           CASE WHEN plan_status = TRUE THEN 1 ELSE 0 END AS plan_not_plan
    FROM donorsearch.donation_plan
),
arg AS (
    SELECT user_id,
           donation_type,
           COUNT(*) AS number_donations,
           SUM(plan_not_plan) AS planned_donations
    FROM planned_donations 
    GROUP BY user_id, donation_type
),
a AS (
    SELECT user_id,
           donation_type,
           number_donations,
           planned_donations,
           ROUND(100.0 * planned_donations / number_donations, 2) AS conversion
    FROM arg
)
SELECT CASE
           WHEN conversion > 75 THEN 'high_planned'
           WHEN conversion >= 50 AND conversion <= 75 THEN 'medium_planned'
           ELSE 'low_planned'
       END AS planned_events,
       donation_type,
       SUM(number_donations) AS sum_donations,
       ROUND(100.0 * SUM(planned_donations) / SUM(number_donations), 2) AS total_conversion
FROM a
GROUP BY planned_events, donation_type
ORDER BY planned_events;

--|planned_events|donation_type|sum_donations|total_conversion|
--|--------------|-------------|-------------|----------------|
--|high_planned  |Платно       |738          |97,56           |
--|high_planned  |Безвозмездно |9 922        |96,91           |
--|low_planned   |Безвозмездно |12 130       |1,06            |
--|low_planned   |Платно       |2 631        |0,61            |
--|medium_planned|Платно       |90           |58,89           |
--|medium_planned|Безвозмездно |2 209        |61,02           |

--Из всего кол-во донаций (27 720) запланировано меньше половины (11 881), то есть большинство донаций носят спонтанный характер.
--Разбив донации на группы по конверсии, можно увидеть следующие значения:
--1.	Конверсия по пол-лю больше 75%, таких донаций 10 660, что составляет 39% от общего числа. 
--Довольно большое кол-во донаций запланировано, конверсия составляет больше 95%.
--2.	Конверсия по пол-лю 50-75 %, таких донаций 2 299, что составляет 8,3% от общего числа донаций. У этой группы большая часть донаций запланированная.
--3.	Конверсия по пол-лю меньше 50%, таких донаций 14 725, что составляет 53,3% от общего числа. 
--У этой группы практически все донации незапланированы, очень маленькая конверсия.
--Стоит отметить, что в каждой группе лишь малое кол-во донаций платные.
--Таким образом, стоит выбрать стратегию на привлечение запланированных донаций, рекомендуется провести мероприятия по мотивации доноров, 
--такие как программы поощрения и улучшение коммуникации о важности донорства.
