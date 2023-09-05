worldcup2014 mysql

CREATE DATABSE worldcup2014;

source /Users/n1c0/SIS/worldcup2014.sql


-- 問題1: 各グループの中でFIFAランクが最も高い国と低い国のランキング番号を表示してください。

SELECT c.group_name AS "グループ", MIN(c.ranking) AS "ランキング最上位", max(c.ranking) AS "ランキング最下位" 
FROM countries c
GROUP BY group_name;


-- 問題2:全ゴールキーパーの平均身長、平均体重を表示してください

SELECT AVG(pl.height) AS "平均身長", AVG(pl.weight) AS "平均体重" 
FROM players pl
WHERE pl.position = "GK";


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

SELECT p.birth, ROUND((TO_DAYS(140613) - (TO_DAYS(p.birth))) / 365) AS age, name, p.position 
FROM players p
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


-- 問題16: グループCの各対戦毎にゴール数を表示してください。

SELECT pa.kickoff AS "kickoff", c1.name AS "my_country", c2.name AS "enemy_country", 
        c1.ranking AS "my_ranking", c2.ranking AS "enemy_ranking", 
        (SELECT COUNT(g.id) FROM goals g WHERE pa.id = g.pairing_id) AS "my_goals",
        (
                SELECT COUNT(g1.id) FROM goals g1 
                LEFT JOIN pairings pa1 ON pa1.id = g1.pairing_id
                WHERE pa1.enemy_country_id = pa.my_country_id 
                        AND pa1.my_country_id = pa.enemy_country_id
        ) AS "enemy_goals",
        (
                (
                        SELECT COUNT(g.id) FROM goals g WHERE pa.id = g.pairing_id
                ) - (
                        SELECT COUNT(g1.id) FROM goals g1 
                        LEFT JOIN pairings pa1 ON pa1.id = g1.pairing_id
                        WHERE pa1.enemy_country_id = pa.my_country_id 
                        AND pa1.my_country_id = pa.enemy_country_id
                )
        ) AS "goal_diff"
FROM pairings pa 
LEFT JOIN countries c1 ON c1.id = pa.my_country_id
LEFT JOIN countries c2 ON c2.id = pa.enemy_country_id
WHERE c1.group_name = "C" AND c2.group_name = "C"
ORDER BY kickoff, my_ranking;


-- 問題17: 問題16の結果に得失点差を追加してください。

SELECT pa.kickoff AS "kickoff", c1.name AS "my_country", c2.name AS "enemy_country", 
        c1.ranking AS "my_ranking", c2.ranking AS "enemy_ranking", 
        (SELECT COUNT(g.id) FROM goals g WHERE pa.id = g.pairing_id) AS "my_goals",
        (
                SELECT COUNT(g1.id) FROM goals g1 
                LEFT JOIN pairings pa1 ON pa1.id = g1.pairing_id
                WHERE pa1.enemy_country_id = pa.my_country_id 
                        AND pa1.my_country_id = pa.enemy_country_id
        ) AS "enemy_goals"
FROM pairings pa 
LEFT JOIN countries c1 ON c1.id = pa.my_country_id
LEFT JOIN countries c2 ON c2.id = pa.enemy_country_id
WHERE c1.group_name = "C" AND c2.group_name = "C"
ORDER BY kickoff, my_ranking;

-- 問題18: ブラジル（my_country_id = 1）対クロアチア（enemy_country_id = 4）戦のキックオフ時間（現地時間）を表示してください。

SELECT pa.kickoff, DATE_ADD(pa.kickoff,INTERVAL -12 HOUR) AS "kickoff_jp"
FROM pairings pa
WHERE pa.my_country_id = 1 AND pa.enemy_country_id = 4;


-- 問題19: 年齢ごとの選手数を表示してください。（年齢はワールドカップ開催当時である2014-06-13を使って算出してください。

SELECT ROUND((TO_DAYS(20140613) - (TO_DAYS(pl.birth))) / 365) AS age, COUNT(pl.id) AS "player_count" 
FROM players pl
GROUP BY age 
ORDER BY age;


-- 問題20: 年齢ごとの選手数を表示してください。ただし、10歳毎に合算して表示してください。

SELECT TRUNCATE((TO_DAYS(20140613) - TO_DAYS(pl.birth)) / 365, -1) AS age, 
        COUNT(pl.id) AS "player_count" 
FROM players pl 
GROUP BY age 
ORDER BY age;


-- 問題21: 年齢ごとの選手数を表示してください。ただし、5歳毎に合算して表示してください。

SELECT TRUNCATE(((TO_DAYS(20140613) - TO_DAYS(pl.birth)) / 365)/5, 0)*5 AS age, 
        COUNT(pl.id) AS "player_count" 
FROM players pl 
GROUP BY age 
ORDER BY age;


-- 問題22: 以下の条件でSQLを作成し、抽出された結果をもとにどのような傾向があるか考えてみてください。

SELECT TRUNCATE(((TO_DAYS(20140613) - TO_DAYS(pl.birth)) / 365)/5, 0)*5 AS age, 
        pl.position, COUNT(pl.id) AS "player_count",
        AVG(pl.height), AVG(pl.weight)
FROM players pl 
GROUP BY age, pl.position 
ORDER BY age, pl.position;


-- 問題23: 身長の高い選手ベスト5を抽出し、以下の項目を表示してください。

SELECT pl.name, pl.height, pl.weight 
FROM players pl 
ORDER BY pl.height desc limit 0,5;


-- 問題24: 身長の高い選手6位～20位を抽出し、以下の項目を表示してください。

SELECT pl.name, pl.height, pl.weight 
FROM players pl 
ORDER BY pl.height desc limit 5, 15;


-- 問題25: 全選手の以下のデータを抽出してください。

SELECT pl.uniform_num, pl.name, pl.club 
FROM players pl;


-- 問題26: グループCに所属する国をすべて抽出してください。

SELECT c.id, c.name, c.ranking, c.group_name 
FROM countries c
WHERE c.group_name = "C";


-- 問題27: グループC以外に所属する国をすべて抽出してください。

SELECT c.id, c.name, c.ranking, c.group_name 
FROM countries c
WHERE c.group_name != "C";


-- 問題28: 2016年1月13日現在で40歳以上の選手を抽出してください。（誕生日の人を含めてください。）

SELECT * 
FROM players 
WHERE DATEDIFF('20160113',birth) >= (40*365);


-- 問題29: 身長が170cm未満の選手を抽出してください。

SELECT * 
FROM players
WHERE height < 170;


-- 問題30: FIFAランクが日本（46位）の前後10位に該当する国（36位～56位）を抽出してください。ただし、BETWEEN句を用いてください。

SELECT * 
FROM countries 
WHERE ranking BETWEEN 36 AND 56;


-- 問題31: 選手のポジションがGK、DF、MFに該当する選手をすべて抽出してください。ただし、IN句を用いてください。

SELECT * 
FROM players
WHERE position IN ('GK','DF','MF');


-- 問題32: オウンゴールとなったゴールを抽出してください。goalsテーブルのplayer_idカラムにNULLが格納されているデータがオウンゴールを表しています。

SELECT *
FROM goals 
WHERE player_id IS NULL;


-- 問題33: オウンゴール以外のゴールを抽出してください。goalsテーブルのplayer_idカラムにNULLが格納されているデータがオウンゴールを表しています。

SELECT *
FROM goals 
WHERE player_id IS NOT NULL;


-- 問題34: 名前の末尾が「ニョ」で終わるプレイヤーを抽出してください。

SELECT * 
FROM players 
WHERE name LIKE '%ニョ';


-- 問題35 :名前の中に「ニョ」が含まれるプレイヤーを抽出してください。

SELECT * 
FROM players 
WHERE name LIKE '%ニョ%';


-- 問題36: グループA以外に所属する国をすべて抽出してください。ただし、「!=」や「<>」を使わずに、「NOT」を使用してください。

SELECT * 
FROM countries 
WHERE NOT group_name IN ('A');


-- 問題37: 全選手の中でBMI値が20台の選手を抽出してください。BMIは以下の式で求めることができます。

SELECT *
FROM players 
WHERE weight / POW(height / 100, 2) BETWEEN 20 AND 21;


-- 問題38: 全選手の中から小柄な選手（身長が165cm未満か、体重が60kg未満）を抽出してください。

SELECT *
FROM players 
WHERE height < 165 OR weight < 60;


-- 問題39: FWかMFの中で170未満の選手を抽出してください。ただし、ORとANDを使用してください。

SELECT *
FROM players
WHERE (position = 'FW' OR position = 'MF') AND height < 170;


-- 問題40: ポジションの一覧を重複なしで表示してください。グループ化は使用しないでください。

SELECT DISTINCT position
FROM players;


-- 問題41: 全選手の身長と体重を足した値を表示してください。合わせて選手の名前、選手の所属クラブも表示してください。

SELECT name, club, height + weight
FROM players;


-- 問題42: 選手名とポジションを以下の形式で出力してください。シングルクォートに注意してください。

SELECT CONCAT(name, '選手のポジションは\'',position,'\'です')
FROM players;


-- 問題43: 全選手の身長と体重を足した値をカラム名「体力指数」として表示してください。合わせて選手の名前、選手の所属クラブも表示してください。

SELECT name, club, weight+height AS "体力指数"
FROM players;


-- 問題44: FIFAランクの高い国から順にすべての国名を表示してください。

SELECT *
FROM countries 
ORDER BY ranking;


-- 問題45: 全ての選手を年齢の低い順に表示してください。なお、年齢を計算する必要はありません。

SELECT * 
FROM players
ORDER BY birth DESC;


-- 問題46: 全ての選手を身長の大きい順に表示してください。同じ身長の選手は体重の重い順に表示してください。

SELECT *
FROM players
ORDER BY height DESC, weight DESC;


-- 問題47: 全ての選手のポジションの1文字目（GKであればG、FWであればF）を出力してください。

SELECT id, country_id, uniform_num, SUBSTRING(position,1,1), name
FROM players;



-- 問題48: 出場国の国名が長いものから順に出力してください。

SELECT name, LENGTH(name) AS "len"
FROM countries
ORDER BY len DESC;


-- 問題49: 全選手の誕生日を「2017年04月30日」のフォーマットで出力してください。

SELECT name, DATE_FORMAT(birth, '%Y年%m月%d日') AS "birthday"
FROM players;


-- 問題50: 全てのゴール情報を出力してください。ただし、オウンゴール（player_idがNULLのデータ）は
--        IFNULL関数を使用してplayer_idを「9999」と表示してください。

SELECT IFNULL(player_id,9999) AS "player_id", goal_time
FROM goals
ORDER BY player_id DESC;


-- 問題51: 全てのゴール情報を出力してください。ただし、オウンゴール（player_idがNULLのデータ）は
--        IFNULL関数を使用してplayer_idを「9999」と表示してください。

SELECT 
        CASE 
                WHEN player_id IS NULL THEN '9999'
                ELSE player_id
        END AS "player_id",
        goal_time
FROM goals
ORDER BY player_id DESC;


-- 問題52: 全ての選手の平均身長、平均体重を表示してください。

SELECT AVG(height) AS "平均身長", AVG(weight) AS "平均体重"
FROM players;


-- 問題53: 日本の選手（player_idが714から736）が上げたゴール数を表示してください。

SELECT COUNT(id) AS "日本のゴール数"
FROM goals
WHERE player_id BETWEEN 714 AND 736;


-- 問題54: オウンゴール（player_idがNULL）以外の総ゴール数を表示してください。ただし、WHERE句は使用しないでください。

SELECT COUNT(player_id) AS "オウンゴール以外のゴール数"
FROM goals;


-- 問題55: 全ての選手の中で最も高い身長と、最も重い体重を表示してください。

SELECT MAX(height) AS "最大身長", MAX(weight) AS "最大体重"
FROM players;


-- 問題56: AグループのFIFAランク最上位を表示してください。

SELECT MIN(ranking) AS "AグループのFIFAランク最上位"
FROM countries
WHERE group_name = 'A';


-- 問題57: CグループのFIFAランクの合計値を表示してください。

SELECT SUM(ranking) AS "CグループのFIFAランクの合計値"
FROM countries
WHERE group_name = 'C';


-- 問題58: 全ての選手の所属国と名前、背番号を表示してください。

SELECT c.name, pl.name, pl.uniform_num
FROM players pl
INNER JOIN countries c ON pl.country_id = c.id;


-- 問題59: 全ての試合の国名と選手名、得点時間を表示してください。オウンゴール（player_idがNULL）は表示しないでください。

SELECT c.name, pl.name, goal_time
FROM players pl
INNER JOIN countries c ON pl.country_id = c.id
INNER JOIN goals g ON pl.id = g.player_id;


-- 問題60: 全ての試合のゴール時間と選手名を表示してください。左側外部結合を使用してオウンゴール（player_idがNULL）も表示してください

SELECT g.goal_time, pl.uniform_num, pl.position, pl.name
FROM goals g
LEFT JOIN players pl ON g.player_id = pl.id;


-- 問題61: 全ての試合のゴール時間と選手名を表示してください。右側外部結合を使用してオウンゴール（player_idがNULL）も表示してください。

SELECT g.goal_time, pl.uniform_num, pl.position, pl.name
FROM players pl
RIGHT JOIN goals g ON pl.id = g.player_id;


-- 問題62: 全ての試合のゴール時間と選手名、国名を表示してください。また、オウンゴール（player_idがNULL）も表示してください。

SELECT c.name AS "country_name", g.goal_time, pl.position, pl.name AS "player_name"
FROM goals g
LEFT JOIN players pl ON g.player_id = pl.id
LEFT JOIN countries c ON pl.country_id = c.id;


-- 問題63: 全ての試合のキックオフ時間と対戦国の国名を表示してください。

SELECT pa.kickoff, c1.name, c2.name
FROM pairings pa
LEFT JOIN countries c1 ON pa.my_country_id = c1.id
LEFT JOIN countries c2 ON pa.enemy_country_id = c2.id;


-- 問題64: 全てのゴール時間と得点を上げたプレイヤー名を表示してください。
--      オウンゴールは表示しないでください。ただし、結合は使わずに副問合せを用いてください。

SELECT g.id, g.goal_time, 
        (SELECT pl.name FROM players pl WHERE pl.id = g.player_id) AS "name"
FROM goals g
WHERE g.player_id IS NOT NULL;


-- 問題65: 全てのゴール時間と得点を上げたプレイヤー名を表示してください。オウンゴールは表示しないでください。
--      ただし、副問合せは使わずに、結合を用いてください。

SELECT g.id, g.goal_time, pl.name
FROM goals g
INNER JOIN players pl ON g.player_id = pl.id;


-- 問題66: 各ポジションごと（GK、FWなど）に最も身長と、その選手名、所属クラブを表示してください。
--      ただし、FROM句に副問合せを使用してください。

SELECT pl1.position, pl1.最大身長, pl2.name, pl2.club
FROM (
        SELECT position,MAX(height) AS "最大身長"
        FROM players
        GROUP BY position
) pl1
LEFT JOIN players pl2 ON pl1.最大身長 = pl2.height AND pl1.position = pl2.position;


-- 問題67: 各ポジションごと（GK、FWなど）に最も身長と、その選手名を表示してください。ただし、SELECT句に副問合せを使用してください。

SELECT pl1.position, MAX(pl1.height) AS "最大身長",
        (SELECT name 
        FROM players pl2 
        WHERE MAX(pl1.height) = pl2.height AND pl1.position = pl2.position) AS "名前"
FROM players pl1
GROUP BY position
ORDER BY position;