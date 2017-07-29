package wallouf.appdirect.dashboard;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Component;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

@Component
@RequestMapping("/")
public class DashboardServlet {

    private static final Logger LOGGER = LoggerFactory.getLogger(DashboardServlet.class);

    @RequestMapping(value = "", method = RequestMethod.GET)
    public String home(final ModelMap pModel, HttpServletRequest request, HttpServletResponse response) {
        return "page_home";
    }

}
