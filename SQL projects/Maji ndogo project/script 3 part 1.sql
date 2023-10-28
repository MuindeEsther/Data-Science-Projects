SELECT * FROM md_water_services.water_quality;
SELECT *
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;
SELECT COUNT(*)
FROM well_pollution
WHERE description LIKE 'Clean_%' OR results = 'Clean' AND biological < 0.01;

SELECT * FROM water_quality WHERE visit_count >= 2 AND subjective_quality_score = 10 ;
SELECT * FROM water_quality WHERE visit_count = 2 OR subjective_quality_score = 10;
SELECT * FROM water_quality WHERE visit_count = 2 AND subjective_quality_score = 10;
SELECT * FROM water_quality WHERE visit_count > 1 AND subjective_quality_score > 10;

SELECT * 
FROM well_pollution
WHERE description
IN ('Parasite: Cryptosporidium', 'biologically contaminated')
OR (results = 'Clean' AND biological > 0.01);