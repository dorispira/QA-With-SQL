SELECT DISTINCT
	(a.ad_name),
	a.ad_id, 
	a.proxy_url AS "VAST Tag", 
	p.pixel_description AS "Pixel Name", 
	CASE WHEN coalesce(p.pixel_detail, p.pixel_detail_ssl)='' THEN p.pixel_detail_ssl ELSE p.pixel_detail END pixel_detail, 
	p.integration_event, 
	ass.click_url, 
	a.status
FROM campaign c 
	JOIN promoted_video pv ON c.campaign_key = pv.campaign_key AND pv.status= 'Active'
	JOIN ad a ON a.promoted_video_id = pv.promoted_video_id AND a.status= 'Active'
	LEFT JOIN ad_pixel ap ON ap.ad_id = a.ad_id AND ap.status= 'Active'
	LEFT JOIN pixel p ON p.pixel_id = ap.pixel_id AND p.status= 'Active' 
	JOIN ad_part adp ON a.ad_id = adp.ad_id AND adp.status= 'Active'
	JOIN asset ass ON adp.ad_part_id = ass.ad_part_id AND ass.status= 'Active'
WHERE c.campaign_id = 642677  
AND a.status <> 'Deleted'
ORDER BY a.ad_name;