import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;

public class service {

    private final repository repo;


    public service(repository repo) {
        this.repo = repo;
    }

    public void add(FinancialProductPreference pref) {
        repo.insert(pref);
    }


    public void update(FinancialProductPreference pref) {
        repo.update(pref);
    }


    public void delete(Long id) {
        repo.delete(id);
    }

    public List<FinancialProductPreference> getAll() {
        return repo.findAll();
    }
}
