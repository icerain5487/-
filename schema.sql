-- =========  使用者 =========
CREATE TABLE user (
    user_id        CHAR(10)     NOT NULL PRIMARY KEY,
    user_name      VARCHAR(50)  NOT NULL,
    email          VARCHAR(100) NOT NULL UNIQUE,
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- =========  扣款帳戶 =========
CREATE TABLE account (
    account_no     CHAR(14)     NOT NULL PRIMARY KEY,
    user_id        CHAR(10)     NOT NULL,
    bank_code      CHAR(3)      NOT NULL,
    account_name   VARCHAR(60),
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_account_user
        FOREIGN KEY (user_id) REFERENCES user(user_id)
        ON DELETE CASCADE
) ENGINE=InnoDB;

-- =========  金融商品主檔 =========
CREATE TABLE financial_product (
    product_id     BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
    product_name   VARCHAR(100) NOT NULL,
    unit_price     DECIMAL(15,2) NOT NULL CHECK (unit_price >= 0),
    fee_rate       DECIMAL(5,4)  NOT NULL CHECK (fee_rate >= 0),
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_product_name (product_name)
) ENGINE=InnoDB;

-- =========  使用者偏好（橋接表） =========
CREATE TABLE favorite (
    favorite_id    BIGINT       NOT NULL AUTO_INCREMENT PRIMARY KEY,
    user_id        CHAR(10)     NOT NULL,
    product_id     BIGINT       NOT NULL,
    account_no     CHAR(14)     NOT NULL,
    quantity       INT          NOT NULL CHECK (quantity > 0),
    created_at     TIMESTAMP    NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at     TIMESTAMP    NULL ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_fav_user      FOREIGN KEY (user_id)    REFERENCES user(user_id)           ON DELETE CASCADE,
    CONSTRAINT fk_fav_product   FOREIGN KEY (product_id) REFERENCES financial_product(product_id),
    CONSTRAINT fk_fav_account   FOREIGN KEY (account_no) REFERENCES account(account_no),
    UNIQUE KEY uk_user_product_account (user_id, product_id, account_no)
) ENGINE=InnoDB;

-- =========  彙總檢視表（供 API 查詢） =========
CREATE VIEW v_favorite_summary AS
SELECT  f.favorite_id,
        u.user_id,
        u.email,
        p.product_name,
        p.unit_price,
        p.fee_rate,
        f.quantity,
        f.account_no,
        ROUND(f.quantity * p.unit_price, 2)                         AS total_amount,
        ROUND(f.quantity * p.unit_price * p.fee_rate, 2)            AS total_fee
FROM    favorite f
JOIN    user u   ON u.user_id   = f.user_id
JOIN    financial_product p ON p.product_id = f.product_id;
