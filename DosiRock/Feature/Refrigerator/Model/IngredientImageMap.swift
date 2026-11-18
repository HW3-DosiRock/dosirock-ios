//
//  IngredientImageMap.swift
//  DosiRock
//

// 서버 name(한국어) → 에셋 이름. 서버가 영문 code를 주면 이 파일만 바꾸면 된다
nonisolated enum IngredientImageMap {

    static let fallback = "logo-stone"

    static func assetName(for name: String) -> String {
        map[name] ?? fallback
    }

    static func isMapped(_ name: String) -> Bool { map[name] != nil }

    private static let map: [String: String] = [
        "양파": "ingredient_vegetable_onion",
        "당근": "ingredient_vegetable_carrot",
        "애호박": "ingredient_vegetable_zucchini",
        "배추": "ingredient_vegetable_napa_cabbage",
        "대파": "ingredient_vegetable_green_onion",
        "고구마": "ingredient_vegetable_sweet_potato",
        "감자": "ingredient_vegetable_potato",
        "양배추": "ingredient_vegetable_cabbage",
        "시금치": "ingredient_vegetable_spinach",
        "상추": "ingredient_vegetable_lettuce",
        "오이": "ingredient_vegetable_cucumber",
        "토마토": "ingredient_vegetable_tomato",
        "무": "ingredient_vegetable_radish",
        "오이맛고추": "ingredient_vegetable_chili_pepper",
        "꽈리고추": "ingredient_vegetable_chili_pepper",
        "청양고추": "ingredient_vegetable_chili_pepper",
        "쪽파": "ingredient_vegetable_chive_onion",
        "가지": "ingredient_vegetable_eggplant",
        "미나리": "ingredient_vegetable_water_dropwort",
        "깻잎": "ingredient_vegetable_perilla_leaf",
        "부추": "ingredient_vegetable_chives",
        "마늘": "ingredient_vegetable_garlic",
        "양상추": "ingredient_vegetable_iceberg_lettuce",
        "콩나물": "ingredient_vegetable_bean_sprouts",
        "팽이버섯": "ingredient_mushroom_enoki",
        "느타리버섯": "ingredient_mushroom_oyster_mushroom",
        "새송이버섯": "ingredient_mushroom_king_oyster_mushroom",
        "양송이버섯": "ingredient_mushroom_button_mushroom",
        "표고버섯": "ingredient_mushroom_shiitake",
        "돼지 앞다리살": "ingredient_meat_pork_shoulder",
        "돼지 목살": "ingredient_meat_pork_neck",
        "삼겹살": "ingredient_meat_pork_belly",
        "삼겹살(수입)": "ingredient_meat_pork_belly_imported",
        "소고기(수입)": "ingredient_meat_beef_imported",
        "닭고기": "ingredient_meat_chicken",
        "마른멸치": "ingredient_seafood_dried_anchovy",
        "북어": "ingredient_seafood_dried_pollack",
        "마른미역": "ingredient_seafood_dried_seaweed",
        "달걀": "ingredient_etc_egg",
        "두부": "ingredient_etc_tofu",
        "우유": "ingredient_etc_milk",
        "맛김": "ingredient_etc_seasoned_laver",
        "김치": "ingredient_etc_kimchi",
        "다진 마늘": "ingredient_seasoning_minced_garlic",
        "간장": "ingredient_seasoning_soy_sauce",
        "소금": "ingredient_seasoning_salt",
        "고추장": "ingredient_seasoning_gochujang",
        "고춧가루": "ingredient_seasoning_chili_powder",
        "깨": "ingredient_seasoning_sesame",
        "새우젓": "ingredient_seasoning_salted_shrimp",
        "멸치액젓": "ingredient_seasoning_anchovy_sauce",
        "건다시마": "ingredient_seasoning_dried_kelp",
        "설탕": "ingredient_seasoning_sugar",
        "된장": "ingredient_seasoning_doenjang",
        "조미료": "ingredient_seasoning_msg",
        "굴소스": "ingredient_seasoning_oyster_sauce",
        "참치액젓": "ingredient_seasoning_tuna_sauce",
        "미림(맛술)": "ingredient_seasoning_mirin",
    ]
}
