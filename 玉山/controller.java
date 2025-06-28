import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;


public class controller {

    private final service service;

    public controller(service service) {
        this.service = service;
    }

    public ResponseEntity<String> create(@RequestBody FinancialProductPreference pref) {
        service.add(pref);
        return ResponseEntity.ok("新增成功");
    }

    public ResponseEntity<List<FinancialProductPreference>> readAll() {
        return ResponseEntity.ok(service.getAll());
    }

    ("/{id}")
    public ResponseEntity<String> update(@PathVariable Long id, @RequestBody FinancialProductPreference pref) {
        pref.setId(id);
        service.update(pref);
        return ResponseEntity.ok("更新成功");
    }
    ("/{id}")
    public ResponseEntity<String> delete(@PathVariable Long id) {
        service.delete(id);
        return ResponseEntity.ok("刪除成功");
    }
}
