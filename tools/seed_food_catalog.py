#!/usr/bin/env python3
"""Seed FitBook 2026 food catalog — organ/body-part chips with distinct foods.

Auth: SUPABASE_ACCESS_TOKEN env var, else macOS keychain item 'Supabase CLI'.
Never hardcode service-role keys in this file.
"""
import json, os, subprocess, urllib.request

REF = "ghhelxjabukfuoxiwqaj"

TM = "https://www.themealdb.com/images/ingredients/{}.png"
# Hosted in Supabase Storage (public) — TheMealDB has no reliable asset for these.
SB = "https://ghhelxjabukfuoxiwqaj.supabase.co/storage/v1/object/public/food-images/foods"

# Proven TheMealDB ingredient file names (HTTP 200)
IMAGES = {
    "Dark chocolate": TM.format("Dark%20Chocolate"),
    "Walnuts": TM.format("Walnuts"),
    "Almonds": TM.format("Almonds"),
    "Salmon": TM.format("Salmon"),
    "Eggs": TM.format("Eggs"),
    "Blueberries": TM.format("Blueberries"),
    "Avocado": TM.format("Avocado"),
    "Spinach": TM.format("Spinach"),
    "Pumpkin seeds": f"{SB}/pumpkin_seeds.jpg",
    "Chia seeds": f"{SB}/chia_seeds.jpg",
    "Oats": TM.format("Oats"),
    "Oatmeal": TM.format("Oatmeal"),
    "Sardines": TM.format("Sardines"),
    "Olive oil": TM.format("Olive%20Oil"),
    "Tomatoes": TM.format("Tomato"),
    "Apples": TM.format("Apple"),
    "Oranges": TM.format("Orange"),
    "Berries": TM.format("Blueberries"),
    "Garlic": TM.format("Garlic"),
    "Ginger": TM.format("Ginger"),
    "Broccoli": TM.format("Broccoli"),
    "Tuna": TM.format("Tuna"),
    "Mackerel": TM.format("Mackerel"),
    "Milk": TM.format("Milk"),
    "Yogurt": TM.format("Yogurt"),
    "Greek yogurt": TM.format("Greek%20yogurt"),
    "Cheese": TM.format("Cheese"),
    "Beef": TM.format("Beef"),
    "Chicken breast": TM.format("Chicken%20Breast"),
    "Lentils": TM.format("Lentils"),
    "Chickpeas": TM.format("Chickpeas"),
    "Brown rice": TM.format("Brown%20Rice"),
    "Quinoa": TM.format("Quinoa"),
    "Bananas": TM.format("Banana"),
    "Carrots": TM.format("Carrots"),
    "Mushrooms": TM.format("Mushrooms"),
    "Kiwi": TM.format("Kiwi"),
    "Lemon": TM.format("Lemon"),
    "Turmeric": TM.format("Turmeric"),
    "Cocoa": TM.format("Cocoa"),
    "Cod": TM.format("Cod"),
    "Shrimp": TM.format("Shrimp"),
    "Pork": TM.format("Pork"),
    "Cucumber": TM.format("Cucumber"),
    "Strawberries": TM.format("Strawberries"),
    "Pumpkin": TM.format("Pumpkin"),
    "Cottage cheese": f"{SB}/cottage_cheese.png",
    "Sweet potatoes": TM.format("Sweet%20Potatoes"),
    "Bell peppers": f"{SB}/bell_peppers.png",
    "Cauliflower": f"{SB}/cauliflower.png",
    "Cabbage": f"{SB}/cabbage.png",
    "Onions": f"{SB}/onions.png",
    "Celery": f"{SB}/celery.png",
    "Corn": f"{SB}/corn.png",
    "Kale": f"{SB}/kale.png",
    "Coffee": f"{SB}/coffee.png",
    "Grapefruit": f"{SB}/grapefruit.png",
    "Tofu": f"{SB}/tofu.png",
    "Papaya": f"{SB}/papaya.png",
    "Guava": f"{SB}/guava.jpg",
    "Kefir": f"{SB}/kefir.jpg",
    "Kimchi": f"{SB}/kimchi.jpg",
    "Sauerkraut": f"{SB}/sauerkraut.png",
    "Raisins": f"{SB}/raisins.png",
    "Dates": f"{SB}/dates.png",
    "Flaxseeds": f"{SB}/flaxseeds.jpg",
    "Beetroot": f"{SB}/beetroot.png",
    "Brazil nuts": f"{SB}/brazil_nuts.jpg",
    "Seaweed": f"{SB}/seaweed.png",
    "Oysters": f"{SB}/oysters.png",
    "Green tea": f"{SB}/green_tea.png",
    "Pomegranate": f"{SB}/pomegranate.png",
    "Potatoes": TM.format("Potato"),
    "Whole grains": TM.format("Brown%20Rice"),
    "Fatty fish": TM.format("Salmon"),
    "Fish": TM.format("Fish"),
    "Nuts": TM.format("Nuts"),
    "Seeds": TM.format("Seeds"),
    "Sesame seeds": TM.format("Sesame%20seed"),
    "Seafood": TM.format("Prawns"),
    "Legumes": TM.format("Lentils"),
    "Vegetables": TM.format("Vegetables"),
    "Beans": f"{SB}/beans.png",
    "Grapes": f"{SB}/grapes.png",
    "Egg whites": TM.format("Eggs"),
    "Liver": TM.format("Beef"),
    "Citrus fruits": TM.format("Orange"),
    "Fermented foods": f"{SB}/fermented_foods.png",
}

EMOJI = {
    "brain": "🧠", "heart": "❤️", "lungs": "🫁", "kidneys": "🫘",
    "liver": "🫀", "bones": "🦴", "eyes": "👁️", "teeth": "🦷",
    "blood": "🩸", "skin": "✨", "hair": "💇", "muscles": "💪",
    "immunity": "🛡️", "stomach": "🍽️", "gut": "🦠", "pancreas": "🩺",
    "thyroid": "🦋", "male": "♂️", "female": "♀️", "circulation": "🩸",
    "nervous": "⚡", "ears": "👂", "spleen": "🩸", "joints": "🦴",
    "pressure": "💓", "cellular": "🔬",
}

# slug, label, emoji, color, sort
GOALS = [
    ("brain", "Brain", "🧠", "#A78BFA", 1),
    ("heart", "Heart", "❤️", "#EF4444", 2),
    ("lungs", "Lungs", "🫁", "#38BDF8", 3),
    ("kidneys", "Kidneys", "🫘", "#14B8A6", 4),
    ("liver", "Liver", "🫀", "#F97316", 5),
    ("bones", "Bones", "🦴", "#EAB308", 6),
    ("eyes", "Eyes", "👁️", "#0EA5E9", 7),
    ("teeth", "Teeth & Gums", "🦷", "#E2E8F0", 8),
    ("blood", "Blood", "🩸", "#DC2626", 9),
    ("skin", "Skin", "✨", "#F472B6", 10),
    ("hair", "Hair & Scalp", "💇", "#60A5FA", 11),
    ("muscles", "Muscles", "💪", "#8B5CF6", 12),
    ("immunity", "Immune System", "🛡️", "#22C55E", 13),
    ("stomach", "Stomach", "🍽️", "#FBBF24", 14),
    ("gut", "Gut & Intestines", "🦠", "#34D399", 15),
    ("pancreas", "Pancreas", "🩺", "#A3E635", 16),
    ("thyroid", "Thyroid", "🦋", "#C084FC", 17),
    ("male", "Male Health", "♂️", "#3B82F6", 18),
    ("female", "Female Health", "♀️", "#EC4899", 19),
    ("circulation", "Circulation", "🩸", "#F43F5E", 20),
    ("nervous", "Nervous System", "⚡", "#FACC15", 21),
    ("ears", "Ears / Hearing", "👂", "#FB923C", 22),
    ("spleen", "Spleen", "🩸", "#94A3B8", 23),
    ("joints", "Joints & Cartilage", "🦴", "#2DD4BF", 24),
    ("pressure", "Blood Pressure", "💓", "#F87171", 25),
    ("cellular", "Cell Protection", "🔬", "#818CF8", 26),
]

# goal_slug: list of (name, why, nutrients, daily, emoji)
CATALOG = {
"brain": [
 ("Dark chocolate","Cocoa flavanols support brain blood flow.",["flavonoids","magnesium"],"20–30 g/day","🍫"),
 ("Chia seeds","Omega-3 ALA supports brain cells.",["omega-3","fiber"],"1 tbsp/day","🌰"),
 ("Walnuts","ALA omega-3 linked with memory.",["omega-3","vitamin E"],"30 g/day","🌰"),
 ("Almonds","Vitamin E supports cognitive health.",["vitamin E","magnesium"],"25–30 g/day","🥜"),
 ("Fatty fish","DHA is a key fat in brain tissue.",["DHA","B12"],"100 g 2–3×/week","🐟"),
 ("Eggs","Choline supports memory-related signaling.",["choline","B12"],"1–2/day","🥚"),
 ("Blueberries","Anthocyanins support healthy brain aging.",["vitamin C","fiber"],"1 cup/day","🫐"),
 ("Avocado","Healthy fats + vitamin E for the brain.",["vitamin E","oleic acid"],"½/day","🥑"),
 ("Spinach","Folate supports nervous system function.",["folate","iron"],"1 cup/day","🥬"),
 ("Pumpkin seeds","Zinc + magnesium for brain health.",["zinc","magnesium"],"20–30 g/day","🎃"),
],
"heart": [
 ("Oats","Beta-glucan helps healthy cholesterol.",["fiber","magnesium"],"40–80 g/day","🥣"),
 ("Salmon","Omega-3 supports heart rhythm.",["omega-3","protein"],"100 g 2×/week","🐟"),
 ("Sardines","Omega-3 + calcium for heart and vessels.",["omega-3","calcium"],"90 g 2×/week","🐟"),
 ("Walnuts","Unsaturated fats support the heart.",["omega-3"],"30 g/day","🌰"),
 ("Almonds","Vitamin E supports cardiovascular health.",["vitamin E"],"25–30 g/day","🥜"),
 ("Chia seeds","Omega-3 + fiber for heart lipids.",["omega-3","fiber"],"1 tbsp/day","🌰"),
 ("Flaxseeds","ALA omega-3 + lignans.",["omega-3","fiber"],"1 tbsp/day","🌾"),
 ("Olive oil","Monounsaturated fat, heart-friendly.",["oleic acid"],"1–2 tbsp/day","🫒"),
 ("Avocado","Healthy fats + potassium.",["potassium","oleic acid"],"½/day","🥑"),
 ("Beans","Soluble fiber supports cholesterol.",["fiber","protein"],"1 cup/day","🫘"),
 ("Berries","Antioxidants for blood vessels.",["vitamin C","polyphenols"],"1 cup/day","🫐"),
 ("Tomatoes","Lycopene supports vascular health.",["lycopene"],"1 cup/day","🍅"),
 ("Spinach","Nitrates + potassium for vessels.",["potassium","nitrates"],"1 cup/day","🥬"),
],
"lungs": [
 ("Apples","Quercetin supports respiratory health.",["quercetin","fiber"],"1/day","🍎"),
 ("Oranges","Vitamin C supports lung defense.",["vitamin C"],"1/day","🍊"),
 ("Guava","Very high vitamin C.",["vitamin C"],"1/day","🍈"),
 ("Berries","Antioxidants support airway health.",["polyphenols"],"1 cup/day","🫐"),
 ("Tomatoes","Lycopene linked with lung function.",["lycopene"],"1 cup/day","🍅"),
 ("Garlic","Sulfur compounds support defenses.",["allicin"],"1–2 cloves/day","🧄"),
 ("Ginger","May soothe airways.",["gingerols"],"1–2 tsp/day","🫚"),
 ("Broccoli","Sulforaphane supports lung tissue.",["vitamin C","sulforaphane"],"1 cup/day","🥦"),
 ("Spinach","Antioxidants for respiratory cells.",["vitamin A","C"],"1 cup/day","🥬"),
 ("Fatty fish","Omega-3 may support lung inflammation balance.",["omega-3"],"100 g 2×/week","🐟"),
 ("Nuts","Vitamin E for lung cells.",["vitamin E"],"25 g/day","🥜"),
],
"kidneys": [
 ("Cauliflower","Light, kidney-friendly veg.",["vitamin C","fiber"],"1 cup/day","🥦"),
 ("Cabbage","Low mineral load, easy on kidneys.",["vitamin K","fiber"],"1 cup/day","🥬"),
 ("Bell peppers","Vitamin C, low potassium vs potatoes.",["vitamin C"],"½ cup/day","🫑"),
 ("Apples","Kidney-friendly fruit.",["fiber"],"1/day","🍎"),
 ("Berries","Low-potassium antioxidants.",["polyphenols"],"1 cup/day","🫐"),
 ("Garlic","Flavor without excess sodium.",["allicin"],"1 clove/day","🧄"),
 ("Onions","Kidney-friendly seasoning.",["quercetin"],"½/day","🧅"),
 ("Olive oil","Healthy fat for kidney diets.",["oleic acid"],"1 tbsp/day","🫒"),
 ("Egg whites","High-quality protein, low phosphorus.",["protein"],"2–4 whites/day","🥚"),
 ("Fish","Quality protein in moderate amounts.",["protein"],"100 g/day","🐟"),
],
"liver": [
 ("Coffee","Linked with healthier liver enzymes.",["caffeine","polyphenols"],"1–2 cups/day","☕"),
 ("Oats","Fiber supports liver fat balance.",["fiber"],"40–80 g/day","🥣"),
 ("Fatty fish","Omega-3 supports liver fat metabolism.",["omega-3"],"100 g 2×/week","🐟"),
 ("Olive oil","Unsaturated fats for liver.",["oleic acid"],"1–2 tbsp/day","🫒"),
 ("Avocado","Healthy fats + glutathione support.",["glutathione"],"½/day","🥑"),
 ("Berries","Antioxidants for liver cells.",["polyphenols"],"1 cup/day","🫐"),
 ("Grapefruit","Naringenin studied for liver health.",["naringenin"],"½/day","🍊"),
 ("Spinach","Antioxidants + fiber.",["folate"],"1 cup/day","🥬"),
 ("Broccoli","Cruciferous support for liver enzymes.",["sulforaphane"],"1 cup/day","🥦"),
 ("Cauliflower","Cruciferous, liver-friendly.",["fiber"],"1 cup/day","🥦"),
 ("Cabbage","Cruciferous support.",["fiber"],"1 cup/day","🥬"),
 ("Garlic","Sulfur compounds for liver enzymes.",["allicin"],"1 clove/day","🧄"),
 ("Walnuts","Arginine + healthy fats.",["arginine","omega-3"],"30 g/day","🌰"),
],
"bones": [
 ("Milk","Calcium + vitamin D for bones.",["calcium","vitamin D"],"1–2 cups/day","🥛"),
 ("Yogurt","Calcium + protein.",["calcium","protein"],"1 cup/day","🥣"),
 ("Cheese","Concentrated calcium.",["calcium"],"30–40 g/day","🧀"),
 ("Sardines","Edible bones = calcium + D.",["calcium","vitamin D"],"90 g 2×/week","🐟"),
 ("Salmon","Vitamin D + protein.",["vitamin D","protein"],"100 g 2×/week","🐟"),
 ("Eggs","Vitamin D + protein for skeleton.",["vitamin D","protein"],"1–2/day","🥚"),
 ("Tofu","Plant protein + calcium (calcium-set).",["protein","calcium"],"100 g/day","⬜"),
 ("Sesame seeds","Calcium for bones.",["calcium"],"1 tbsp/day","🌰"),
 ("Chia seeds","Calcium + omega-3.",["calcium","omega-3"],"1 tbsp/day","🌰"),
 ("Almonds","Magnesium + calcium.",["magnesium","calcium"],"25 g/day","🥜"),
 ("Spinach","Vitamin K + magnesium.",["vitamin K"],"1 cup/day","🥬"),
],
"eyes": [
 ("Carrots","Beta-carotene → vitamin A for vision.",["vitamin A"],"1/day","🥕"),
 ("Sweet potatoes","Rich beta-carotene.",["vitamin A"],"1 medium/day","🍠"),
 ("Spinach","Lutein + zeaxanthin for macula.",["lutein"],"1 cup/day","🥬"),
 ("Kale","Lutein for macular pigment.",["lutein","vitamin K"],"1 cup/day","🥬"),
 ("Eggs","Lutein in yolks supports retina.",["lutein","zinc"],"1–2/day","🥚"),
 ("Salmon","DHA in retinal tissues.",["DHA","omega-3"],"100 g 2×/week","🐟"),
 ("Sardines","Omega-3 + vitamin D.",["omega-3","vitamin D"],"90 g 2×/week","🐟"),
 ("Oranges","Vitamin C for eye vessels.",["vitamin C"],"1/day","🍊"),
 ("Bell peppers","High vitamin C for eyes.",["vitamin C"],"½ cup/day","🫑"),
 ("Corn","Lutein + zeaxanthin.",["lutein"],"½ cup/day","🌽"),
 ("Pumpkin","Beta-carotene for night vision.",["beta-carotene"],"1 cup/day","🎃"),
],
"teeth": [
 ("Milk","Calcium strengthens enamel support.",["calcium","protein"],"1–2 cups/day","🥛"),
 ("Yogurt","Calcium + probiotics for gums.",["calcium","probiotics"],"1 cup/day","🥣"),
 ("Cheese","Calcium + pH support after meals.",["calcium"],"20–30 g/day","🧀"),
 ("Apples","Chewing + mild cleansing effect.",["fiber"],"1/day","🍎"),
 ("Carrots","Crunchy, stimulates saliva.",["beta-carotene"],"1/day","🥕"),
 ("Celery","Fibrous, saliva-friendly crunch.",["fiber"],"1 stalk/day","🥬"),
 ("Spinach","Vitamin K + calcium.",["vitamin K"],"1 cup/day","🥬"),
 ("Almonds","Calcium + protein for teeth.",["calcium"],"25 g/day","🥜"),
 ("Eggs","Vitamin D helps calcium use.",["vitamin D"],"1/day","🥚"),
 ("Fatty fish","Vitamin D for mineral balance.",["vitamin D"],"100 g 2×/week","🐟"),
],
"blood": [
 ("Beef","Heme iron for hemoglobin.",["iron","B12","protein"],"100–150 g/day","🥩"),
 ("Liver","Very high bioavailable iron.",["iron","B12"],"30–50 g 1–2×/week","🫀"),
 ("Eggs","Iron + B12 for blood cells.",["iron","B12"],"1–2/day","🥚"),
 ("Spinach","Non-heme iron + folate.",["iron","folate"],"1 cup/day","🥬"),
 ("Lentils","Plant iron + folate.",["iron","folate"],"1 cup/day","🫘"),
 ("Chickpeas","Iron + protein.",["iron","protein"],"1 cup/day","🫘"),
 ("Beans","Iron + fiber.",["iron","fiber"],"1 cup/day","🫘"),
 ("Pumpkin seeds","Iron + zinc.",["iron","zinc"],"20 g/day","🎃"),
 ("Sesame seeds","Iron + calcium.",["iron"],"1 tbsp/day","🌰"),
 ("Raisins","Iron for everyday snacks.",["iron"],"30 g/day","🍇"),
 ("Dates","Iron + quick energy.",["iron"],"2–3/day","🌴"),
],
"skin": [
 ("Avocado","Healthy fats + vitamin E for moisture.",["vitamin E"],"½/day","🥑"),
 ("Fatty fish","Omega-3 supports skin barrier.",["omega-3","protein"],"100 g 2×/week","🐟"),
 ("Walnuts","Omega-3 for supple skin.",["omega-3"],"30 g/day","🌰"),
 ("Almonds","Vitamin E for skin cells.",["vitamin E"],"25 g/day","🥜"),
 ("Chia seeds","Omega-3 + minerals.",["omega-3"],"1 tbsp/day","🌰"),
 ("Tomatoes","Lycopene vs daily stress.",["lycopene","vitamin C"],"1 cup/day","🍅"),
 ("Carrots","Beta-carotene for skin tone.",["beta-carotene"],"1/day","🥕"),
 ("Sweet potatoes","Vitamin A for skin renewal.",["vitamin A"],"1 medium/day","🍠"),
 ("Berries","Antioxidants for glow.",["vitamin C","polyphenols"],"1 cup/day","🫐"),
 ("Citrus fruits","Vitamin C for collagen.",["vitamin C"],"1/day","🍊"),
 ("Bell peppers","Very high vitamin C.",["vitamin C"],"½ cup/day","🫑"),
],
"hair": [
 ("Eggs","Protein + biotin for hair structure.",["protein","biotin"],"1–2/day","🥚"),
 ("Fatty fish","Omega-3 + D for scalp.",["omega-3","vitamin D"],"100 g 2×/week","🐟"),
 ("Greek yogurt","Protein + B vitamins.",["protein","B5"],"1 cup/day","🥣"),
 ("Lentils","Plant iron + protein.",["iron","protein"],"1 cup/day","🫘"),
 ("Beans","Iron + protein for follicles.",["iron","protein"],"1 cup/day","🫘"),
 ("Spinach","Iron + folate for growth.",["iron","folate"],"1 cup/day","🥬"),
 ("Pumpkin seeds","Zinc for hair tissue.",["zinc"],"20 g/day","🎃"),
 ("Walnuts","Biotin + vitamin E.",["biotin","vitamin E"],"30 g/day","🌰"),
 ("Almonds","Vitamin E for scalp.",["vitamin E"],"25 g/day","🥜"),
 ("Avocado","Healthy fats for hair shine.",["vitamin E"],"½/day","🥑"),
 ("Sweet potatoes","Beta-carotene for scalp sebum.",["vitamin A"],"1 medium/day","🍠"),
],
"muscles": [
 ("Eggs","Complete protein + leucine.",["protein","leucine"],"2–3/day","🥚"),
 ("Chicken breast","Lean protein for repair.",["protein","B6"],"120–200 g/day","🍗"),
 ("Fish","Protein + omega-3 recovery.",["protein","omega-3"],"120 g/day","🐟"),
 ("Beef","Iron + protein for strength.",["iron","protein"],"100–150 g/day","🥩"),
 ("Milk","Whey + casein after training.",["protein","calcium"],"1–2 cups/day","🥛"),
 ("Greek yogurt","Slow casein protein.",["protein","calcium"],"1 cup/day","🥣"),
 ("Cottage cheese","Casein for overnight recovery.",["protein","calcium"],"1 cup/day","🧀"),
 ("Lentils","Plant protein + iron.",["protein","iron"],"1 cup/day","🫘"),
 ("Chickpeas","Plant protein + carbs.",["protein","fiber"],"1 cup/day","🫘"),
 ("Beans","Protein + fiber for satiety.",["protein","fiber"],"1 cup/day","🫘"),
 ("Tofu","Complete plant protein.",["protein"],"100 g/day","⬜"),
 ("Nuts","Protein + healthy fats.",["protein","magnesium"],"25 g/day","🥜"),
],
"immunity": [
 ("Citrus fruits","Vitamin C for immune cells.",["vitamin C"],"1/day","🍊"),
 ("Guava","Exceptional vitamin C.",["vitamin C"],"1/day","🍈"),
 ("Kiwi","Vitamin C + fiber.",["vitamin C"],"1–2/day","🥝"),
 ("Bell peppers","High vitamin C.",["vitamin C"],"½ cup/day","🫑"),
 ("Broccoli","Vitamin C + sulforaphane.",["vitamin C"],"1 cup/day","🥦"),
 ("Garlic","Allicin for immune defense.",["allicin"],"1–2 cloves/day","🧄"),
 ("Ginger","Gingerols for immune comfort.",["gingerols"],"1–2 tsp/day","🫚"),
 ("Yogurt","Probiotics for gut immunity.",["probiotics"],"1 cup/day","🥣"),
 ("Eggs","Protein + vitamin D.",["protein","vitamin D"],"1–2/day","🥚"),
 ("Mushrooms","Beta-glucans for immune signaling.",["beta-glucans"],"1 cup/day","🍄"),
 ("Nuts","Vitamin E + zinc.",["vitamin E","zinc"],"25 g/day","🥜"),
 ("Seeds","Zinc + selenium.",["zinc"],"20 g/day","🌰"),
],
"stomach": [
 ("Yogurt","Probiotics support the stomach.",["probiotics"],"1 cup/day","🥣"),
 ("Kefir","Diverse probiotics.",["probiotics"],"1 cup/day","🥛"),
 ("Oats","Gentle soluble fiber.",["fiber"],"40–80 g/day","🥣"),
 ("Bananas","Gentle on the stomach.",["fiber","potassium"],"1/day","🍌"),
 ("Ginger","Soothes nausea/discomfort.",["gingerols"],"1–2 tsp/day","🫚"),
 ("Papaya","Papain enzymes aid digestion.",["papain","vitamin C"],"1 cup/day","🍑"),
 ("Whole grains","Fiber for digestion.",["fiber"],"1–2 servings/day","🌾"),
 ("Fermented foods","Support stomach flora.",["probiotics"],"small serving/day","🥣"),
 ("Chia seeds","Gel-forming fiber.",["fiber"],"1 tbsp/day","🌰"),
 ("Vegetables","Fiber + micronutrients.",["fiber","vitamin C"],"2+ cups/day","🥬"),
],
"gut": [
 ("Yogurt","Probiotics for gut flora.",["probiotics"],"1 cup/day","🥣"),
 ("Kefir","Strong probiotic drink.",["probiotics"],"1 cup/day","🥛"),
 ("Kimchi","Fermented veggies for gut.",["probiotics"],"small serving/day","🥬"),
 ("Sauerkraut","Fermented cabbage.",["probiotics"],"small serving/day","🥬"),
 ("Oats","Prebiotic fiber.",["fiber"],"40–80 g/day","🥣"),
 ("Bananas","Feeds good bacteria.",["fiber","potassium"],"1/day","🍌"),
 ("Apples","Pectin prebiotic.",["fiber"],"1/day","🍎"),
 ("Onions","Prebiotic fibers.",["fiber"],"½/day","🧅"),
 ("Garlic","Prebiotic + allicin.",["allicin","fiber"],"1 clove/day","🧄"),
 ("Lentils","High fiber for regularity.",["fiber","protein"],"1 cup/day","🫘"),
 ("Beans","Resistant starch + fiber.",["fiber"],"1 cup/day","🫘"),
 ("Chia seeds","Gel fiber for gut.",["fiber"],"1 tbsp/day","🌰"),
 ("Flaxseeds","Fiber + lignans.",["fiber"],"1 tbsp/day","🌾"),
],
"pancreas": [
 ("Spinach","Antioxidants for metabolic support.",["folate","iron"],"1 cup/day","🥬"),
 ("Broccoli","Cruciferous support.",["vitamin C"],"1 cup/day","🥦"),
 ("Cauliflower","Light, low-glycemic veg.",["fiber"],"1 cup/day","🥦"),
 ("Berries","Low-sugar antioxidants.",["polyphenols"],"1 cup/day","🫐"),
 ("Whole grains","Steady energy, fiber.",["fiber","magnesium"],"1–2 servings/day","🌾"),
 ("Beans","Fiber + plant protein.",["fiber","protein"],"1 cup/day","🫘"),
 ("Lentils","Low-glycemic protein.",["fiber","protein"],"1 cup/day","🫘"),
 ("Fatty fish","Omega-3 metabolic support.",["omega-3"],"100 g 2×/week","🐟"),
 ("Nuts","Healthy fats + magnesium.",["magnesium"],"25 g/day","🥜"),
 ("Olive oil","Unsaturated fats.",["oleic acid"],"1 tbsp/day","🫒"),
],
"thyroid": [
 ("Seafood","Iodine for thyroid hormones.",["iodine","protein"],"2–3×/week","🦐"),
 ("Fish","Iodine + selenium.",["iodine","selenium"],"100 g 2×/week","🐟"),
 ("Eggs","Iodine + selenium.",["iodine","selenium"],"1–2/day","🥚"),
 ("Milk","Iodine + protein.",["iodine","calcium"],"1–2 cups/day","🥛"),
 ("Yogurt","Iodine + probiotics.",["iodine"],"1 cup/day","🥣"),
 ("Brazil nuts","Selenium for thyroid enzymes.",["selenium"],"1–2/day","🥜"),
 ("Seaweed","Natural iodine source.",["iodine"],"small amount/week","🌿"),
],
"male": [
 ("Oysters","Zinc for male reproductive health.",["zinc"],"4–6, 1–2×/week","🦪"),
 ("Eggs","Protein + vitamin D.",["protein","vitamin D"],"1–2/day","🥚"),
 ("Fatty fish","Omega-3 for circulation.",["omega-3"],"100 g 2×/week","🐟"),
 ("Pumpkin seeds","Zinc + antioxidants.",["zinc","magnesium"],"20–30 g/day","🎃"),
 ("Walnuts","Arginine + omega-3.",["omega-3"],"30 g/day","🌰"),
 ("Spinach","Nitrates support blood flow.",["nitrates","folate"],"1 cup/day","🥬"),
 ("Pomegranate","Antioxidants for vascular health.",["polyphenols"],"1/day or juice","🍎"),
 ("Avocado","Healthy fats + vitamin E.",["vitamin E"],"½/day","🥑"),
],
"female": [
 ("Eggs","Protein + choline.",["choline","protein"],"1–2/day","🥚"),
 ("Fatty fish","Omega-3 + vitamin D.",["omega-3","vitamin D"],"100 g 2×/week","🐟"),
 ("Lentils","Iron + folate.",["iron","folate"],"1 cup/day","🫘"),
 ("Beans","Iron + fiber.",["iron","fiber"],"1 cup/day","🫘"),
 ("Spinach","Folate + iron.",["folate","iron"],"1 cup/day","🥬"),
 ("Broccoli","Cruciferous support.",["vitamin C","fiber"],"1 cup/day","🥦"),
 ("Avocado","Healthy fats.",["vitamin E"],"½/day","🥑"),
 ("Nuts","Magnesium + healthy fats.",["magnesium"],"25 g/day","🥜"),
 ("Seeds","Zinc + fiber.",["zinc","fiber"],"20 g/day","🌰"),
 ("Berries","Antioxidants.",["polyphenols"],"1 cup/day","🫐"),
],
"circulation": [
 ("Beetroot","Nitrates support blood flow.",["nitrates"],"1 cup or juice/day","🫑"),
 ("Spinach","Nitrates + magnesium.",["nitrates"],"1 cup/day","🥬"),
 ("Berries","Vascular antioxidants.",["polyphenols"],"1 cup/day","🫐"),
 ("Citrus fruits","Vitamin C for vessel walls.",["vitamin C"],"1/day","🍊"),
 ("Garlic","Supports healthy circulation.",["allicin"],"1–2 cloves/day","🧄"),
 ("Fatty fish","Omega-3 for blood lipids.",["omega-3"],"100 g 2×/week","🐟"),
 ("Walnuts","Omega-3 + arginine.",["omega-3"],"30 g/day","🌰"),
 ("Flaxseeds","ALA omega-3 + fiber.",["omega-3","fiber"],"1 tbsp/day","🌾"),
 ("Olive oil","Monounsaturated fats.",["oleic acid"],"1–2 tbsp/day","🫒"),
 ("Avocado","Healthy fats + potassium.",["potassium"],"½/day","🥑"),
],
"nervous": [
 ("Fatty fish","DHA for nerve tissue.",["DHA","omega-3"],"100 g 2×/week","🐟"),
 ("Eggs","B12 + choline for nerves.",["B12","choline"],"1–2/day","🥚"),
 ("Walnuts","Omega-3 for neural support.",["omega-3"],"30 g/day","🌰"),
 ("Almonds","Magnesium + vitamin E.",["magnesium","vitamin E"],"25 g/day","🥜"),
 ("Pumpkin seeds","Magnesium for nerve calm.",["magnesium"],"20 g/day","🎃"),
 ("Chia seeds","Omega-3 + magnesium.",["omega-3"],"1 tbsp/day","🌰"),
 ("Avocado","Healthy fats + B vitamins.",["vitamin E","B6"],"½/day","🥑"),
 ("Spinach","Magnesium + folate.",["magnesium","folate"],"1 cup/day","🥬"),
 ("Whole grains","B vitamins for nerves.",["B vitamins"],"1–2 servings/day","🌾"),
 ("Legumes","Magnesium + protein.",["magnesium","protein"],"1 cup/day","🫘"),
],
"ears": [
 ("Fatty fish","Omega-3 may support inner ear blood flow.",["omega-3"],"100 g 2×/week","🐟"),
 ("Walnuts","Healthy fats for ear cells.",["omega-3"],"30 g/day","🌰"),
 ("Almonds","Magnesium + vitamin E.",["magnesium"],"25 g/day","🥜"),
 ("Pumpkin seeds","Magnesium + zinc.",["zinc","magnesium"],"20 g/day","🎃"),
 ("Spinach","Magnesium for circulation.",["magnesium"],"1 cup/day","🥬"),
 ("Broccoli","Antioxidants + vitamin C.",["vitamin C"],"1 cup/day","🥦"),
 ("Citrus fruits","Vitamin C for micro-vessels.",["vitamin C"],"1/day","🍊"),
 ("Eggs","Vitamin D + protein.",["vitamin D"],"1–2/day","🥚"),
],
"spleen": [
 ("Beans","Iron + plant protein.",["iron","protein"],"1 cup/day","🫘"),
 ("Lentils","Iron + folate.",["iron","folate"],"1 cup/day","🫘"),
 ("Spinach","Iron + antioxidants.",["iron"],"1 cup/day","🥬"),
 ("Berries","Antioxidants.",["polyphenols"],"1 cup/day","🫐"),
 ("Citrus fruits","Vitamin C helps iron absorb.",["vitamin C"],"1/day","🍊"),
 ("Fish","Protein + micronutrients.",["protein","selenium"],"100 g/day","🐟"),
 ("Eggs","Iron + B12.",["iron","B12"],"1–2/day","🥚"),
 ("Whole grains","Fiber + minerals.",["fiber","magnesium"],"1–2 servings/day","🌾"),
 ("Nuts","Zinc + healthy fats.",["zinc"],"25 g/day","🥜"),
 ("Seeds","Iron + zinc.",["iron","zinc"],"20 g/day","🌰"),
],
"joints": [
 ("Fatty fish","Omega-3 for joint comfort.",["omega-3"],"100 g 2×/week","🐟"),
 ("Sardines","Omega-3 + calcium.",["omega-3","calcium"],"90 g 2×/week","🐟"),
 ("Salmon","Omega-3 + vitamin D.",["omega-3","vitamin D"],"100 g 2×/week","🐟"),
 ("Walnuts","ALA omega-3.",["omega-3"],"30 g/day","🌰"),
 ("Chia seeds","Omega-3 + minerals.",["omega-3"],"1 tbsp/day","🌰"),
 ("Flaxseeds","ALA omega-3.",["omega-3"],"1 tbsp/day","🌾"),
 ("Berries","Antioxidants for cartilage.",["polyphenols"],"1 cup/day","🫐"),
 ("Oranges","Vitamin C for collagen.",["vitamin C"],"1/day","🍊"),
 ("Broccoli","Vitamin C + sulforaphane.",["vitamin C"],"1 cup/day","🥦"),
 ("Olive oil","Healthy fats.",["oleic acid"],"1 tbsp/day","🫒"),
],
"pressure": [
 ("Bananas","Potassium helps blood pressure.",["potassium"],"1/day","🍌"),
 ("Potatoes","Potassium-rich staple.",["potassium"],"1 medium/day","🥔"),
 ("Spinach","Nitrates + potassium.",["potassium","nitrates"],"1 cup/day","🥬"),
 ("Avocado","Potassium + healthy fats.",["potassium"],"½/day","🥑"),
 ("Beans","Potassium + fiber.",["potassium","fiber"],"1 cup/day","🫘"),
 ("Lentils","Potassium + plant protein.",["potassium"],"1 cup/day","🫘"),
 ("Oats","Fiber for cardiovascular balance.",["fiber"],"40–80 g/day","🥣"),
 ("Yogurt","Calcium + potassium.",["calcium","potassium"],"1 cup/day","🥣"),
 ("Beetroot","Nitrates support healthy BP.",["nitrates"],"1 cup/day","🫑"),
 ("Fatty fish","Omega-3 for vessels.",["omega-3"],"100 g 2×/week","🐟"),
],
"cellular": [
 ("Blueberries","Anthocyanins protect cells.",["polyphenols","vitamin C"],"1 cup/day","🫐"),
 ("Strawberries","Vitamin C antioxidants.",["vitamin C"],"1 cup/day","🍓"),
 ("Pomegranate","Punicalagin antioxidants.",["polyphenols"],"1/day","🍎"),
 ("Dark chocolate","Cocoa polyphenols.",["flavonoids"],"20–30 g/day","🍫"),
 ("Green tea","Catechins for antioxidant defense.",["catechins"],"2–3 cups/day","🍵"),
 ("Tomatoes","Lycopene antioxidant.",["lycopene"],"1 cup/day","🍅"),
 ("Spinach","Broad antioxidant support.",["vitamin C","K"],"1 cup/day","🥬"),
 ("Broccoli","Sulforaphane cellular support.",["sulforaphane"],"1 cup/day","🥦"),
 ("Grapes","Resveratrol + polyphenols.",["polyphenols"],"1 cup/day","🍇"),
 ("Nuts","Vitamin E antioxidant.",["vitamin E"],"25 g/day","🥜"),
 ("Turmeric","Curcumin cellular support.",["curcumin"],"1 tsp/day","🟡"),
],
}


def table_name(url):
    if not url:
        return ""
    return url.split("/")[-1]


def main():
    token = os.environ.get("SUPABASE_ACCESS_TOKEN", "").strip()
    if not token:
        token = subprocess.check_output(
            ["bash", "-lc", "security find-generic-password -s 'Supabase CLI' -w"]
        ).decode().strip()
    if not token:
        raise SystemExit("Missing SUPABASE_ACCESS_TOKEN (or keychain 'Supabase CLI')")

    def sql(q):
        req = urllib.request.Request(
            f"https://api.supabase.com/v1/projects/{REF}/database/query",
            data=json.dumps({"query": q}).encode(),
            headers={
                "Authorization": f"Bearer {token}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=180) as r:
            return r.status, r.read().decode()[:250]

    print("clear", sql("delete from public.foods; delete from public.food_goals;"))

    gvals = []
    for slug, label, emoji, color, order in GOALS:
        gvals.append(f"('{slug}','{label}','{emoji}','{color}',{order})")
    print("goals", sql(
        "insert into public.food_goals (slug,label,emoji,color_hex,sort_order) values "
        + ",".join(gvals) + ";"
    ))

    fvals = []
    n = 0
    for slug, items in CATALOG.items():
        for name, why, nuts, daily, emoji in items:
            n += 1
            img = IMAGES.get(name)
            nuts_sql = "ARRAY[" + ",".join(f"'{x}'" for x in nuts) + "]"
            why_e = why.replace("'", "''")
            img_sql = f"'{img}'" if img else "NULL"
            rid = f"{slug[:4]}{n:03d}"
            fvals.append(
                f"('{rid}','{name}','{slug}','{why_e}',{nuts_sql},'{daily}',"
                f"'{name}','{name}','{emoji}',{img_sql},{n})"
            )
    print("food rows", len(fvals))
    # chunk inserts
    chunk = 40
    for i in range(0, len(fvals), chunk):
        part = fvals[i:i+chunk]
        q = (
            "insert into public.foods "
            "(id,name,goal_slug,why,key_nutrients,daily_amount,fdc_query,spoon_query,emoji,image_url,sort_order) values "
            + ",".join(part)
            + " on conflict (id) do nothing;"
        )
        st, body = sql(q)
        print("chunk", i, st, body[:80])

    st, body = sql("select goal_slug, count(*) from public.foods group by goal_slug order by goal_slug")
    print("counts", body)
    st, body = sql("select id,name,image_url from public.foods where name ilike '%sweet%' limit 5")
    print("sweet potato rows", body)


if __name__ == "__main__":
    main()
