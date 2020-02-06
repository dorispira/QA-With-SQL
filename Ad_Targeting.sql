SELECT DISTINCT cp.campaign_id as "Campaign ID", 
		p.package_name as "Package Name", 
		cp.campaign_placement_name as "Placement Name", 
		a.ad_name as "Ad Name", mt.metro_name as DMA, 
		pc.postal_code_name as "Zip Codes", 
		s.state_name as States,cty.country_name as "Country", 
		cp.is_custom_ad_scheduling_enabled as "Is Custom Ad Scheduling Enabled?", 
		f.flight_name as "Ad Scheduling Evenly Weighted?", 
		f.start_date "Ad Scheduling Start Date", 
		f.end_date as "Ad Scheduling End Date", 
		f.weight as "Ad Weight"
FROM campaign_placement cp 
JOIN promoted_ad pa on cp.campaign_placement_id = pa.campaign_placement_id
JOIN ad a on pa.ad_id = a.ad_id
LEFT JOIN package p on cp.package_id = p.package_id
LEFT JOIN campaign_metro_targeting cm on cp.campaign_placement_id = cm.campaign_placement_id and cm.status='Active'
LEFT JOIN metro mt on cm.metro_id = mt.metro_id
LEFT JOIN campaign_postal_code_targeting cpc on cp.campaign_placement_id = cpc.campaign_placement_id and cpc.status='Active'
LEFT JOIN postal_code pc on pc.postal_code_id = cpc.postal_code_id  
LEFT JOIN campaign_state_targeting cst on cp.campaign_placement_id = cst.campaign_placement_id and cst.status='Active'
LEFT JOIN state s on s.state_id = cst.state_id 
LEFT JOIN campaign_country_targeting cct on cp.campaign_placement_id = cct.campaign_placement_id and cct.status= 'Active'
LEFT JOIN country cty on cct.country_id = cty.country_id
LEFT JOIN (
		SELECT f.campaign_placement_id, f.flight_name, f.start_date, f.end_date, fa.ad_id, fa.weight
		FROM flight f 
		JOIN flight_ad fa 
		ON f.flight_id=fa.flight_id
		WHERE f.status='Active' and fa.status='Active'
	) f 
ON cp.campaign_placement_id = f.campaign_placement_id and a.ad_id=f.ad_id
WHERE cp.campaign_id = '635179';
