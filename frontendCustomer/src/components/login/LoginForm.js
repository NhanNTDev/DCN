import validator from "validator";
import { Link, useNavigate, useSearchParams } from "react-router-dom";

import { Spin, notification, Button } from "antd";
import userApi from "../../apis/userApi";
import { LoadingOutlined } from "@ant-design/icons";
import { setUser } from "../../state_manager_redux/user/userSlice";
import { useState } from "react";
import { useDispatch } from "react-redux";
import { setLocation } from "../../state_manager_redux/location/locationSlice";
import { auth } from "../../firebase/firebase";
import { RecaptchaVerifier, signInWithPhoneNumber } from "firebase/auth";

const LoginForm = () => {
  const [userName, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [confirmPassword, setConfirmPassword] = useState("");
  const [invalidOtp, setInvalidOtp] = useState(false);
  const [loginFail, setLoginFail] = useState(false);
  const [showPassword, setShowPassword] = useState(false);
  const [validateMsg, setValidateMsg] = useState("");
  const [searchParams] = useSearchParams();
  const [otp, setOtp] = useState("");
  const [currentUi, setCurrentUi] = useState("login");
  const urlRedirect = searchParams.get("urlRedirect");
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const antIcon = <LoadingOutlined style={{ fontSize: 32 }} spin />;
  const [loading, setLoading] = useState(false);
  const handleLogin = () => {
    setLoginFail(false);
    const isValid = validateAll();
    if (!isValid) return;
    setLoading(true);
    const login = async () => {
      const result = await userApi.login({ userName, password }).catch(() => {
        setLoginFail(true);
        setLoading(false);
      });
      if (result && result.user.role === "customer") {
        const setUserAction = setUser({ ...result });
        if (result.user.address !== null && result.user.address !== "") {
          const setLocationAction = setLocation({
            location: result.user.address,
          });
          dispatch(setLocationAction);
        }
        dispatch(setUserAction);
        urlRedirect !== null ? navigate(`${urlRedirect}`) : navigate("/home");
        notification.success({
          duration: 3,
          message: "????ng nh???p th??nh c??ng",
          style: { fontSize: 16 },
        });
      }
    };
    login();
  };

  const handleResetPassword = () => {
    setLoading(true);
    const params = {
      username: userName,
      password: password,
    }
    const resetPassword = async () => {
      await userApi.resetPassword(params).then(() => {
        notification.success({duration: 2, 
        message: "?????t l???i m???t kh???u th??nh c??ng!", style: {fontSize: 16}})
        goToLogin();
      }).catch(() => {
        notification.error(({duration: 2,
        message: "T??i kho???n kh??ng t???n t???i!", style:{fontSize: 16}}));
        goToResetPassword();
      }) 
      setLoading(false);
    }
    resetPassword();
  };
  const generateRecapcha = () => {
    window.recaptchaVerifier = new RecaptchaVerifier(
      "sign-in-button",
      {
        size: "invisible",
        callback: (response) => {
          // reCAPTCHA solved, allow signInWithPhoneNumber.
        },
      },
      auth
    );
  };

  const sentOtp = async () => {
    const valid = await validateAll();
    if (!valid) return;
    auth.settings.appVerificationDisabledForTesting = false;
    generateRecapcha();
    let appVerifier = window.recaptchaVerifier;
    signInWithPhoneNumber(auth, "+84" + userName.substring(1, 10), appVerifier)
      .then((confirmationResult) => {
        window.confirmationResult = confirmationResult;
        setCurrentUi("otp");
      })
      .catch((err) => {
        // Error; SMS not sent
        console.log(err);
      });
  };

  const verifyOtp = () => {
    let confirmationResult = window.confirmationResult;
    confirmationResult
      .confirm(otp)
      .then((result) => {
        handleResetPassword();
      })
      .catch((error) => {
        setInvalidOtp(true);
      });
  };

  const goToLogin = () => {
    setCurrentUi("login");
    setValidateMsg([]);
    setUsername("");
    setPassword("");
    setConfirmPassword("");
    setOtp("");
  };
  const goToResetPassword = () => {
    setCurrentUi("resetPassword");
    setValidateMsg([]);
    setUsername("");
    setPassword("");
    setConfirmPassword("");
    setOtp("");
    setLoginFail(false);
  }
  const onChangeUserName = (event) => {
    setUsername(event.target.value);
  };
  const onChangePassword = (event) => {
    setPassword(event.target.value);
  };

  const onChangeConfirmPassword = (event) => {
    setConfirmPassword(event.target.value);
  };

  const validateAll = () => {
    const msg = {};
    if (validator.isEmpty(userName)) {
      msg.userName = "Vui l??ng nh???p m???c n??y";
    }
    if (validator.isEmpty(password)) {
      msg.password = "Vui l??ng nh???p m???c n??y";
    }
    if (currentUi === "resetPassword") {
      if (password !== confirmPassword) {
        msg.confirmPassword = "M???t kh???u kh??ng kh???p";
      }
    }
    setValidateMsg(msg);
    if (Object.keys(msg).length > 0) return false;
    return true;
  };
  return (
    <>
      <div className="d-flex justify-content-center">
        {loading ? (
          <>
            <Spin indicator={antIcon} /> <br /> <br />{" "}
          </>
        ) : null}
      </div>
      {currentUi === "login" && (
        <>
          <h5 className="heading-design-h5">????ng nh???p v??o t??i kho???n c???a b???n</h5>
          <fieldset className="form-group">
            <label>S??? ??i???n tho???i *</label>
            <input
              required
              value={userName}
              onKeyPress={(e) => {
                if (e.key === "Enter") handleLogin();
              }}
              onChange={onChangeUserName}
              type="text"
              className="form-control"
              placeholder="nh???p email/s??? ??i???n tho???i..."
            />
            <span style={{ color: "red" }}>{validateMsg.userName}</span>
          </fieldset>
          <fieldset className="form-group">
            <label>M???t kh???u *</label>
            <input
              required
              type={showPassword ? "text" : "password"}
              value={password}
              onKeyPress={(e) => {
                if (e.key === "Enter") handleLogin();
              }}
              onChange={onChangePassword}
              className="form-control"
              placeholder="nh???p m???t kh???u..."
            />
            <span
              id="show-password-btn"
              onClick={() => {
                setShowPassword(!showPassword);
              }}
              className={showPassword ? "mdi mdi-eye-off" : "mdi mdi-eye"}
            ></span>

            <span style={{ color: "red" }}>{validateMsg.password}</span>
          </fieldset>
          <fieldset className="form-group">
            <button
              className="btn btn-lg btn-secondary btn-block"
              onClick={handleLogin}
            >
              ????ng nh???p
            </button>
          </fieldset>
          {loginFail && (
            <fieldset className="form-group">
              <span style={{ color: "red" }}>
                T??n ????ng nh???p ho???c m???t kh???u kh??ng ch??nh x??c
              </span>
            </fieldset>
          )}
          <div className="custom-control custom-checkbox">
            <div className="float-right">
              <Button onClick={goToResetPassword} type="link">
                Qu??n m???t kh???u
              </Button>{" "}
            </div>
          </div>
        </>
      )}
      {currentUi === "resetPassword" && (
        <>
          <h5 className="heading-design-h5">?????t l???i m???t kh???u</h5>
          <fieldset className="form-group">
            <label>S??? ??i???n tho???i *</label>
            <input
              required
              value={userName}
              onKeyPress={(e) => {
                if (e.key === "Enter") handleResetPassword();
              }}
              onChange={onChangeUserName}
              type="text"
              className="form-control"
              placeholder="nh???p email/s??? ??i???n tho???i..."
            />
            <span style={{ color: "red" }}>{validateMsg.userName}</span>
          </fieldset>
          <fieldset className="form-group">
            <label>M???t kh???u m???i: *</label>
            <input
              required
              type={showPassword ? "text" : "password"}
              value={password}
              onKeyPress={(e) => {
                if (e.key === "Enter") handleResetPassword();
              }}
              onChange={onChangePassword}
              className="form-control"
              placeholder="nh???p m???t kh???u..."
            />
            <span
              id="show-password-btn"
              onClick={() => {
                setShowPassword(!showPassword);
              }}
              className={showPassword ? "mdi mdi-eye-off" : "mdi mdi-eye"}
            ></span>

            <span style={{ color: "red" }}>{validateMsg.password}</span>
          </fieldset>
          <fieldset className="form-group">
            <label>Nh???p l???i m???t kh???u: *</label>
            <input
              required
              type={showPassword ? "text" : "password"}
              value={confirmPassword}
              onKeyPress={(e) => {
                if (e.key === "Enter") handleLogin();
              }}
              onChange={onChangeConfirmPassword}
              className="form-control"
              placeholder="nh???p m???t kh???u..."
            />
            <span
              id="show-password-btn"
              onClick={() => {
                setShowPassword(!showPassword);
              }}
              className={showPassword ? "mdi mdi-eye-off" : "mdi mdi-eye"}
            ></span>

            <span style={{ color: "red" }}>{validateMsg.confirmPassword}</span>
          </fieldset>
          <fieldset className="form-group">
            <button
              className="btn btn-lg btn-secondary btn-block"
              onClick={sentOtp}
            >
              ?????t l???i
            </button>
          </fieldset>
          <div className="custom-control custom-checkbox">
            <div className="float-right">
              <Button onClick={goToLogin} type="link">
                V??? trang ????ng nh???p
              </Button>{" "}
            </div>
          </div>
          <div id="sign-in-button"></div>
        </>
      )}
      {currentUi === "otp" && (
        <>
          <fieldset className="form-group">
            <label>X??c nh???n m?? OTP:</label>
            <input
              type="text"
              className="form-control"
              placeholder="Nh???p m?? OTP"
              value={otp}
              onChange={(e) => {
                setOtp(e.target.value);
              }}
            />
            {invalidOtp && (
              <span
                className="d-flex justify-content-center"
                style={{ color: "red" }}
              >
                M?? OTP kh??ng ????ng!
              </span>
            )}
          </fieldset>
          <div className="custom-control custom-checkbox">
            <div className="float-right">
              <Button
                onClick={goToLogin}
                type="link"
              >
                V??? trang ????ng nh???p
              </Button>{" "}
            </div>
          </div>
          <br />
          <br />
          <fieldset className="form-group">
            <button
              className="btn btn-lg btn-secondary btn-block"
              onClick={verifyOtp}
            >
              X??c nh???n
            </button>
          </fieldset>
        </>
      )}
    </>
  );
};

export default LoginForm;
