import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import javax.sql.DataSource;
import java.util.*;

public class repository {

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcCall spInsert, spUpdate, spDelete, spSelectAll;


    public repository(DataSource dataSource) {
        this.jdbcTemplate = new JdbcTemplate(dataSource);
        this.spInsert = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_insert_preference");
        this.spUpdate = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_update_preference");
        this.spDelete = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_delete_preference");
        this.spSelectAll = new SimpleJdbcCall(jdbcTemplate).withProcedureName("sp_select_all_preferences");
    }

    public void insert(FinancialProductPreference pref) {
        Map<String, Object> params = new HashMap<>();
        params.put("p_product_name", pref.getProductName());
        params.put("p_product_price", pref.getProductPrice());
        params.put("p_fee_rate", pref.getFeeRate());
        params.put("p_account_number", pref.getAccountNumber());
        params.put("p_purchase_quantity", pref.getPurchaseQuantity());
        params.put("p_user_email", pref.getUserEmail());
        spInsert.execute(params);
    }

    public void update(FinancialProductPreference pref) {
        Map<String, Object> params = new HashMap<>();
        params.put("p_id", pref.getId());
        params.put("p_product_name", pref.getProductName());
        params.put("p_product_price", pref.getProductPrice());
        params.put("p_fee_rate", pref.getFeeRate());
        params.put("p_account_number", pref.getAccountNumber());
        params.put("p_purchase_quantity", pref.getPurchaseQuantity());
        spUpdate.execute(params);
    }

    public void delete(Long id) {
        Map<String, Object> params = new HashMap<>();
        params.put("p_id", id);
        spDelete.execute(params);
    }

    public List<FinancialProductPreference> findAll() {
        Map<String, Object> result = spSelectAll.execute();
        List<Map<String, Object>> list = (List<Map<String, Object>>) result.get("result_cursor");
        List<FinancialProductPreference> prefs = new ArrayList<>();
        if (list != null) {
            for (Map<String, Object> row : list) {
                FinancialProductPreference pref = new FinancialProductPreference();
                pref.setId(((Number) row.get("id")).longValue());
                pref.setProductName((String) row.get("product_name"));
                pref.setProductPrice(new java.math.BigDecimal(row.get("product_price").toString()));
                pref.setFeeRate(new java.math.BigDecimal(row.get("fee_rate").toString()));
                pref.setAccountNumber((String) row.get("account_number"));
                pref.setPurchaseQuantity((Integer) row.get("purchase_quantity"));
                pref.setUserEmail((String) row.get("user_email"));
                prefs.add(pref);
            }
        }
        return prefs;
    }
}
