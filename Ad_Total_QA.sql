set @campaign = 624475; -- Enter Campaign ID here
SELECT DISTINCT cp.campaign_id as "Campaign ID", 
                p.package_name as "Package Name", 
                cp.campaign_placement_name as "Placement Name",
                cp.campaign_placement_id,
                cm.metro_names as DMA, 
                cpc.num_postal_codes as "Zip Codes", 
                cst.state_names as States,
                cst.targeting_type,
                cty.country_name as "Country",
                pf.optimization_goal,
                t.topic_name, 
                ctt.included, 
                par.partner_name,
                cp.site_safety_block, 
                bs.brand_safety_category_name,
                cp.status as "Placement Status"

FROM (
        SELECT DISTINCT cp.campaign_placement_id, 
                        pa.ad_id, cp.status, 
                        cp.campaign_id, 
                        cp.campaign_placement_name, 
                        cp.site_safety_block, 
                        cp.package_id
        FROM promoted_ad pa 
        JOIN campaign_placement cp on cp.campaign_placement_id = pa.campaign_placement_id
        WHERE cp.campaign_id=@campaign
    ) cp
    JOIN ad a on cp.ad_id = a.ad_id
    LEFT JOIN package p on cp.package_id = p.package_id

-- DMA QA

    LEFT JOIN (
        SELECT cm.campaign_placement_id, group_concat(mt.metro_name SEPARATOR ', ') metro_names
        FROM campaign_metro_targeting cm
        JOIN campaign_placement cp on cm.campaign_placement_id=cp.campaign_placement_id
        JOIN metro mt on cm.metro_id = mt.metro_id
        WHERE cm.status='Active' AND cp.campaign_id = @campaign
        GROUP BY cm.campaign_placement_id
    ) cm 
    ON cp.campaign_placement_id = cm.campaign_placement_id 

-- Zip codes QA

    LEFT JOIN (
        SELECT cpc.campaign_placement_id, count(*) num_postal_codes
        FROM campaign_postal_code_targeting cpc
        JOIN campaign_placement cp on cpc.campaign_placement_id=cp.campaign_placement_id
        WHERE cpc.status='Active' AND cp.campaign_id=@campaign
        GROUP BY cpc.campaign_placement_id
    ) cpc 
    ON cp.campaign_placement_id = cpc.campaign_placement_id 

-- State QA

    LEFT JOIN (
        SELECT cst.campaign_placement_id, cst.targeting_type, count(s.state_name) as "state_names"
        FROM campaign_state_targeting cst
        JOIN campaign_placement cp on cst.campaign_placement_id=cp.campaign_placement_id
        LEFT JOIN state s on cst.state_id = s.state_id
        WHERE cp.campaign_id=@campaign AND cst.status='Active'
        GROUP BY cp.campaign_placement_id

    ) cst 
    ON cp.campaign_placement_id = cst.campaign_placement_id

-- Country QA

    LEFT JOIN campaign_country_targeting cct on cp.campaign_placement_id = cct.campaign_placement_id and cct.status= 'Active'
    LEFT JOIN country cty on cct.country_id = cty.country_id

-- Ad Scheduling QA

    LEFT JOIN (
        SELECT f.campaign_placement_id, 
            f.flight_name, 
            f.start_date, 
            f.end_date, 
            fa.ad_id, 
            fa.weight
        FROM flight f 
        JOIN flight_ad fa on f.flight_id=fa.flight_id
        WHERE f.status='Active' and fa.status='Active'
    ) f 
    ON cp.campaign_placement_id = f.campaign_placement_id and a.ad_id=f.ad_id

-- Prebid filters QA

    LEFT JOIN (
    	SELECT cpo.campaign_placement_id, 
            cpo.optimization_goal_target, 
            group_concat(og.optimization_goal_name SEPARATOR ', ') optimization_goal
    	FROM optimization_goal og
    	JOIN campaign_placement_optimization_goal cpo on og.optimization_goal_id = cpo.optimization_goal_id
    	JOIN campaign_placement cp on cp.campaign_placement_id = cpo.campaign_placement_id
    	WHERE cp.campaign_id=@campaign
    	GROUP BY cp.campaign_placement_id
    ) pf 
    ON cp.campaign_placement_id = pf.campaign_placement_id
    	
-- Topic targeting QA

    LEFT JOIN campaign_topic_targeting ctt on ctt.campaign_placement_id = cp.campaign_placement_id
    LEFT JOIN topic t on t.topic_id = ctt.topic_id 
    LEFT JOIN partner par on t.partner_id = par.partner_id

-- Brand safety QA

	LEFT JOIN (
		SELECT cpbscl.campaign_placement_id, group_concat(bsc.brand_safety_category_name SEPARATOR ', ') brand_safety_category_name
		FROM brand_safety_category bsc
		JOIN campaign_placement_brand_safety_category_list cpbscl on bsc.brand_safety_category_id = cpbscl.brand_safety_category_id
		JOIN campaign_placement cp on cp.campaign_placement_id = cpbscl.campaign_placement_id
		WHERE cp.campaign_id=@campaign
		GROUP BY cp.campaign_placement_id
	) bs 
    ON cp.campaign_placement_id = bs.campaign_placement_id
		
WHERE cp.campaign_id=@campaign and cp.status <> 'Deleted'


