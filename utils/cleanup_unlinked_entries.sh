DELETE failed_variation FROM failed_variation LEFT JOIN variation ON failed_variation.variation_id = variation.variation_id WHERE variation.variation_id IS NULL;

