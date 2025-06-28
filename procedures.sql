DELIMITER $$

-- 新增喜好（含交易）
CREATE PROCEDURE sp_add_favorite (
    IN p_user_id     CHAR(10),
    IN p_product_id  BIGINT,
    IN p_account_no  CHAR(14),
    IN p_quantity    INT
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;
    START TRANSACTION;

    -- 確認帳號屬於該使用者
    IF NOT EXISTS (SELECT 1 FROM account WHERE account_no = p_account_no AND user_id = p_user_id)
    THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = '帳號與使用者不符';
    END IF;

    INSERT INTO favorite (user_id, product_id, account_no, quantity)
    VALUES (p_user_id, p_product_id, p_account_no, p_quantity)
    ON DUPLICATE KEY UPDATE
        quantity = p_quantity,
        updated_at = CURRENT_TIMESTAMP;

    COMMIT;
END$$

-- 依使用者查詢喜好清單 (含總計)
CREATE PROCEDURE sp_get_favorites_by_user (
    IN  p_user_id CHAR(10)
)
BEGIN
    SELECT  product_name,
            account_no,
            SUM(total_amount) AS total_amount,
            SUM(total_fee)    AS total_fee,
            email
    FROM    v_favorite_summary
    WHERE   user_id = p_user_id
    GROUP BY product_name, account_no, email;
END$$

-- 更新喜好（同時可動態調整產品價格 → 示範跨表 Transaction）
CREATE PROCEDURE sp_update_favorite (
    IN p_favorite_id  BIGINT,
    IN p_quantity     INT,
    IN p_new_price    DECIMAL(15,2)
)
BEGIN
    DECLARE v_product_id BIGINT;

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK; RESIGNAL;
    END;
    START TRANSACTION;

    SELECT product_id INTO v_product_id
    FROM   favorite
    WHERE  favorite_id = p_favorite_id
    FOR UPDATE;

    IF v_product_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Favorite not found';
    END IF;

    -- 1. 更新數量
    UPDATE favorite
       SET quantity   = p_quantity,
           updated_at = CURRENT_TIMESTAMP
     WHERE favorite_id = p_favorite_id;

    -- 2. 可選：若產品需同步改價
    UPDATE financial_product
       SET unit_price = p_new_price
     WHERE product_id = v_product_id;

    COMMIT;
END$$

-- 刪除喜好
CREATE PROCEDURE sp_delete_favorite (IN p_favorite_id BIGINT)
BEGIN
    DELETE FROM favorite WHERE favorite_id = p_favorite_id;
END$$

DELIMITER ;
