worldcup2014 mysql

CREATE DATABSE worldcup2014;

source /Users/n1c0/SIS/worldcup2014.sql


-- 問題1: 各グループの中でFIFAランクが最も高い国と低い国のランキング番号を表示してください。

SELECT group_name AS "グループ", MIN(ranking) AS "ランキング最上位", max(ranking) AS "ランキング最下位" 
FROM countries 
GROUP BY group_name;


-- 問題2:全ゴールキーパーの平均身長、平均体重を表示してください

SELECT AVG(height) AS "平均身長", AVG(weight) AS "平均体重" 
FROM players 
WHERE position = "GK";


-- 問題3: 各国の平均身長を高い方から順に表示してください。ただし、FROM句はcountriesテーブルとしてください。

SELECT c.name AS "国名", AVG(pl.height) AS "平均身長" 
FROM countries c 
INNER JOIN players pl on c.id = pl.country_id 
GROUP BY c.name 
ORDER BY AVG(p.height) DESC;


-- 問題4: 国の平均身長を高い方から順に表示してください。ただし、FROM句はplayersテーブルとして、テーブル結合を使わず副問合せを用いてください。

SELECT (SELECT c.name FROM countries c WHERE pl.country_id = c.id) AS "国名", 
        AVG(pl.height) AS "平均身長" 
FROM players p
GROUP BY pl.country_id 
ORDER BY AVG(p.height) DESC;


-- 問題5: キックオフ日時と対戦国の国名をキックオフ日時の早いものから順に表示してください。

SELECT DISTINCT pa.kickoff AS "キックオフ日時", c1.name AS "国名1", c2.name AS "国名2"
FROM pairings pa
LEFT JOIN countries c1 ON pa.my_country_id = c1.id 
LEFT JOIN countries c2 ON pa.enemy_country_id = c2.id 
WHERE c1.id < c2.id 
ORDER BY kickoff;


-- 問題6: すべての選手を対象として選手ごとの得点ランキングを表示してください。(SELECT句で副問合せを使うこと)

SELECT pl.name AS "名前", pl.position AS "ポジション", pl.club AS "所属クラブ",
        (SELECT COUNT(g.id) FROM goals g WHERE pl.id = g.player_id) AS "ゴール数"
FROM players pl 
WHERE (SELECT COUNT(g.id) FROM goals g WHERE pl.id = g.player_id) > 0 
ORDER BY ゴール数 DESC;


-- 問題7: すべての選手を対象として選手ごとの得点ランキングを表示してください。（テーブル結合を使うこと）

SELECT pl.name AS "名前", pl.position AS "ポジション", pl.club AS "所属クラブ",
        COUNT(g.id) AS "ゴール数"
FROM players pl
LEFT JOIN goals g ON pl.id = g.player_id
GROUP BY pl.name, pl.position, pl.club
HAVING COUNT(g.id) > 0
ORDER BY ゴール数 DESC;


-- 問題8: 各ポジションごとの総得点を表示してください。

SELECT position AS "ポジション",
        COUNT(g.id) AS "ゴール数"
FROM players pl 
LEFT JOIN goals g ON pl.id = g.player_id 
GROUP BY pl.position 
ORDER BY ゴール数 DESC;


-- 問題9: ワールドカップ開催当時(2014-06-13)の年齢をプレイヤー毎に表示する。

SELECT birth, ROUND((TO_DAYS(140613) - (TO_DAYS(birth))) / 365) AS age, name, position 
FROM players 
ORDER BY age DESC;


-- 問題10: オウンゴールの回数を表示する

SELECT COUNT(g.goal_time) 
FROM goals g
WHERE player_id IS NULL;


-- 問題11: 各グループごとの総得点数を表示して下さい。

SELECT c.group_name, COUNT(g.id) 
FROM goals g
LEFT JOIN pairings pa ON pa.id = g.pairing_id
LEFT JOIN countries c ON c.id = pa.my_country_id
WHERE pa.kickoff BETWEEN DATE('2014-6-13') AND DATE('2014-6-27')+1
GROUP BY c.group_name
ORDER BY c.group_name;


-- 問題12: 日本VSコロンビア戦(pairings.id = 103)でのコロンビアの得点のゴール時間を表示してください

SELECT goal_time 
FROM goals 
WHERE pairing_id = 103;


-- 問題13: 日本VSコロンビア戦の勝敗を表示して下さい。

SELECT c.name AS "name", COUNT(g.goal_time) 
FROM goals g
LEFT JOIN pairings pa ON pa.id = g.pairing_id
LEFT JOIN countries c ON c.id = pa.my_country_id
WHERE g.pairing_id = 39 
        OR g.pairing_id = 103
GROUP BY c.name
ORDER BY COUNT(g.goal_time);


-- 問題14: グループCの各対戦毎にゴール数を表示してください。

SELECT pa.kickoff AS "kickoff", c1.name AS "my_country", c2.name AS "enemy_country", 
        c1.ranking AS "my_ranking", c2.ranking AS "enemy_ranking", COUNT(g.goal_time) AS "my_goals" 
FROM pairings pa 
LEFT JOIN countries c1 ON c1.id = pa.my_country_id
LEFT JOIN countries c2 ON c2.id = pa.enemy_country_id
LEFT JOIN goals g ON pa.id = g.pairing_id
WHERE c1.group_name = "C" AND c2.group_name = "C"
GROUP BY kickoff, my_country, enemy_country, my_ranking, enemy_ranking
ORDER BY kickoff, my_ranking;


-- 問題15: グループCの各対戦毎にゴール数を表示してください。

SELECT pa.kickoff AS "kickoff", c1.name AS "my_country", c2.name AS "enemy_country", 
        c1.ranking AS "my_ranking", c2.ranking AS "enemy_ranking", 
        (SELECT COUNT(g.id) FROM goals g WHERE pa.id = g.pairing_id) AS "my_goals" 
FROM pairings pa 
LEFT JOIN countries c1 ON c1.id = pa.my_country_id
LEFT JOIN countries c2 ON c2.id = pa.enemy_country_id
WHERE c1.group_name = "C" AND c2.group_name = "C"
ORDER BY kickoff, my_ranking;