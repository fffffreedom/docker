# harbor

harbor实现HA，对接OA等实现细节笔记。

## HA方案

```
                                                |-> Harbor A ->| 
peoples -> Internet -> vip (keepalived+HAproxy) |              | -> vip -> mysql(需要做HA)
                                                |-> Harbor A ->|
```

注：mysql和harbor其它组件可以共用一个vip（部署在同一台主机上时）

### 问题

#### 镜像复制和删除问题

由于共享一个mysql，通过VIP登录WEB配置同步规则时，一个project需要配置两个规则（由物理机数目决定）；
但VIP存在于其中的一台物理上，这会导致镜像复制规则的源IP和目标IP一样，也就不需要进行镜像同步。
所以需要在镜像同步的源码中，添加IP判断，如果相同，则返回或者跳过该流程。

复制规则中会包含目标registry的IP，我们需要将当前主机的IP添加到jobservice的env文件中，然后在代码
中去获取，进行判断。可在各阶段的Enter函数中添加判断，如果IP一致，则跳到下一步骤，直到结束。  

```
// Enter ...
func (i *Initializer) Enter() (string, error) {
    ...

    //添加IP判断
	myHarborUrl := os.Getenv("HARBOR_URL")
	if (myHarborUrl == i.dstURL) {
		i.logger.Info("Initial=========")
		return StateCheck, nil
	}
	
    ...
}
```

同样，在删除镜像时，也需要做如下判断，防止自已删除自己！

```
func (d *Deleter) Enter() (string, error) {
	d.logger.Info("INDeleter=========")
	myHarborUrl := os.Getenv("HARBOR_URL")
	if (myHarborUrl == d.dstURL) {
		d.logger.Info("Deleter=========")
		return models.JobFinished, nil
	}
	...
}
```

## 对接OA

### ui/controller/cas.go

```
package controllers

import (
	"net/http"
	"strings"
	"github.com/astaxie/beego"
	"github.com/vmware/harbor/src/common/utils/log"
	"io/ioutil"
	"encoding/json"
	"github.com/vmware/harbor/src/common/models"
	"github.com/vmware/harbor/src/common/dao"
	"strconv"
	"github.com/astaxie/beego/context"
)

const (
	defaultPwd = "Harbor12345"
)

type CasController struct {
	beego.Controller
}

//OA相关的字段，由公司的OA决定
type OaUserInfo struct {
	FUserID         string `json:"FUserID"`
	FUserName       string `json:"FUserName"`
	FUserNamePinyin string `json:"FUserNamePinyin"`
	FOAEmail        string `json:"FOAEmail"`
	FOAUserName     string `json:"FOAUserName"`
	FDepartmentName string `json:"FDepartmentName"`
	FDepartment     string `json:"FDepartment"`
	FDeptManagerID  string `json:"FDeptManagerID"`
}

func IsTokenFound(cookie []*http.Cookie) bool {
	return GetToken(cookie) != ""
}

func GetToken(cookie []*http.Cookie) string {
	for _, v := range cookie {
		cv := *v;
		if cv.Name == "Token" {
			//log.Debug("toker=", cv.Value)
			return cv.Value
		}
	}
	return ""
}

//验证从request中获取到的cookie是否合法
func SetUserInfo(ctx *context.Context, cookie []*http.Cookie) bool {
	// 验证token是否有效
	tokenInCookie := GetToken(cookie)
	if tokenInCookie == "" {
		ctx.WriteString("Token is empty!")
		return false
	}

	// 查看用户是否已存在，否则注册用户
	oaUser := OaUserInfo{}
	if (isValidToken(tokenInCookie[len("Value="):], &oaUser)) {
		// set token into session
		ctx.Input.CruSession.Set("token", tokenInCookie)

		user := models.User{}
		//user.Username = oaUser.FUserName
		user.Username = oaUser.FUserID

		exist, err := dao.UserExists(user, "username")
		if err != nil {
			log.Error("check UserExists error")
			ctx.WriteString("dao UserExists error")
			return false
		}

		if !exist {
			// set user info
			user.HasAdminRole = 0
			user.Password = defaultPwd
			user.Deleted = 0
			user.Email = oaUser.FOAEmail
			user.Realname = oaUser.FUserNamePinyin

			// register user
			userID, err := dao.Register(user)
			if err != nil {
				log.Error("dao Register error")
				ctx.WriteString("dao Register error")
				return false
			}
			user.UserID, _ = strconv.Atoi(strconv.FormatInt(userID, 10))
		} else {
			userInDB, err := dao.GetUser(user)
			if err != nil {
				log.Error("GetUser error")
				ctx.WriteString("dao GetUser error")
				return false
			}
			user.UserID = userInDB.UserID
			user.Username = userInDB.Username
		}

		ctx.Input.CruSession.Set("userId", user.UserID)
		ctx.Input.CruSession.Set("username", user.Username)
		//log.Debugf("userID = %d, username = %s", user.UserID, user.Username)

	} else {
		log.Error("Token is invalid, token =", tokenInCookie)
		ctx.WriteString("Token is invalid")
		return false
	}

	return true
}

//登出时，删除cookie
func (cc *CasController) Logout() {
	log.Debug("+++++++++ Logout")
	cc.Ctx.SetCookie("Token", "", -1, "/", "vv.xyz")
	cc.DestroySession()
}

func isValidToken(token string, oa *OaUserInfo) bool {
	//构建toker验证请求
	cmd := XXXXX
	
	contentType := "application/x-www-form-urlencoded;charset=utf-8"

	resp, err := http.Post(URL, contentType, strings.NewReader(cmd))
	if err != nil {
		log.Error("post error")
		return false
	}

	if resp.StatusCode != http.StatusOK {
		log.Error("resp.StatusCode=", resp.StatusCode)
		return false
	}
  
  //读取并验证
	body, err := ioutil.ReadAll(resp.Body)
	//log.Debug("out=", string(body))

	s := string(body)
	sa := strings.Split(s, "\n")

	total := len(sa[1])
	start := len("<string>[")
	end := total - len("]</string>")

	temp := sa[1][start:end]
	json.Unmarshal([]byte(temp), oa)
	
	return true
}

// Render returns nil.
func (cc *CasController) Render() error {
	return nil
}

```

### ui/main.go

```
func main() {
    ...
    // 拦截所有页面，如果没有登录，则重定向到OA登录界面
    var PageFilter = func(ctx *context.Context) {
        //http请求路径
        //log.Debug("RequestURI: ", ctx.Request.RequestURI)
        
        //查看是否存在合法的cookies，不存在则跳转到OA页面登录
        cookies := ctx.Request.Cookies()
        ok := controllers.IsTokenFound(cookies)
        if ok {
            controllers.SetUserInfo(ctx, cookies)
        } else {
            OaURL := "http://[YOUR-COMPANY-OA-URL]/userlogin.aspx?BackURL="

        HarborURL := os.Getenv("HARBOR_URL")
        if HarborURL == "" {
            HarborURL := "http://"
            HarborURL += ctx.Request.Host
        }
        log.Info("HarborURL ==> ", HarborURL)

        // 由于拦截了所有页面，service和api相关的请求都被拦截了
        // 这里做下判断，不对/service和/api相关的请求进行拦截
        if  strings.Contains(ctx.Request.RequestURI, "/service") ||
            strings.Contains(ctx.Request.RequestURI, "/api") {
            log.Debugf("@@@@@ return ", ctx.Request.RequestURI)
            return
        }

        if ctx.Request.RequestURI == "/" ||
            strings.Contains(ctx.Request.RequestURI, "/sign-in") ||
            strings.Contains(ctx.Request.RequestURI, "/sign-up") {
            HarborURL += "/harbor/projects"
        } else {
            HarborURL += ctx.Request.RequestURI
        }
        RedirectURL := OaURL + url.QueryEscape(HarborURL)

        log.Debugf(RedirectURL)
        ctx.Redirect(302, RedirectURL)
    }

    // 拦截所有路径，不需要拦截的在函数里做判断
    beego.InsertFilter("/*",beego.BeforeRouter, PageFilter)
    ...
}
```

### 问题

在代码中，无法通过`ctx.Request.URL`获取到harbor的域名，需要将域名保存到ui的evn文件中，然后在代码中通过环境变量获取。
