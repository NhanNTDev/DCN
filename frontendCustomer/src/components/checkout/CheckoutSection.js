import { useEffect, useState } from "react";
import { useDispatch, useSelector } from "react-redux";
import { Link, useNavigate, useSearchParams } from "react-router-dom";
import orderApi from "../../apis/orderApi";
import cartApi from "../../apis/cartApi";
import { Spin, Radio, Space, notification } from "antd";
import { LoadingOutlined } from "@ant-design/icons";
import { setCart } from "../../state_manager_redux/cart/cartSlice";
import addressApi from "../../apis/addressApis";
import {
  getCartTotal,
  getOrderCouter,
} from "../../state_manager_redux/cart/cartSelector";
import CreateAddressForm from "../address/CreateAddressFrom";
import momoApi from "../../apis/momoApi";
import LoadingPage from "../../pages/LoadingPage";
import { isMobile } from "react-device-detect";
import { parseTimeDMY } from "../../utils/Common";
const CheckoutSection = () => {
  const order = useSelector((state) => state.order);
  const cart = useSelector((state) => state.cart);
  const user = useSelector((state) => state.user);
  const [loading, setLoading] = useState(false);
  const antIcon = <LoadingOutlined style={{ fontSize: 32 }} spin />;
  const [addresses, setAddresses] = useState([]);
  const orderCount = useSelector(getOrderCouter);
  const [selectedAddress, setSelectedAddress] = useState();
  const [currentStep, setCurrentStep] = useState(1);
  const [changePlag, setChangePlag] = useState(true);
  const [paymentMethod, setPaymentMethod] = useState(1);
  const [shipCost, setShipCost] = useState(0);
  const navigate = useNavigate();
  const dispatch = useDispatch();
  const cartTotal = useSelector(getCartTotal);
  const [searchParams] = useSearchParams();
  const orderType = searchParams.get("orderType");
  const [momoLoading, setMomoLoading] = useState(false);
  useEffect(() => {
    if (orderType === "momo_wallet") {
      setMomoLoading(true);
      const fetchCartItems = async () => {
        const cartItemsResponse = await cartApi.getAll(user.id);
        const action = setCart(cartItemsResponse);
        dispatch(action);
      };
      const checkoutMomo = async () => {
        const checkoutUrl = window.location.href;
        await momoApi
          .checkoutMomo(checkoutUrl)
          .then((result) => {
            if (result === "Thanh to??n th??nh c??ng!") {
              fetchCartItems();
              setCurrentStep(4);
            } else {
              notification.error({
                duration: 3,
                message: "Thanh to??n th???t b???i",
                style: { fontSize: 16 },
              });
            }
          })
          .catch((err) => {
            if (err.message === "Network Error") {
              notification.error({
                duration: 3,
                message: "M???t k???t n???i m???ng!",
                style: { fontSize: 16 },
              });
            } else {
              notification.error({
                duration: 3,
                message: "Thanh to??n th???t b???i",
                style: { fontSize: 16 },
              });
            }
            setCurrentStep(1);
          });

        setMomoLoading(false);
      };
      checkoutMomo();
      return;
    } else if (orderCount === 0) {
      navigate("/cart");
    }
  }, []);
  useEffect(() => {
    const fetchAddess = async () => {
      await addressApi
        .getAll(user.id)
        .then((result) => {
          if (result !== null) {
            setAddresses(result);
            setSelectedAddress(result[0]);
          }
        })
        .catch((err) =>
          notification.error({
            duration: 3,
            message: "c?? l???i x???y ra trong qu?? tr??nh x??? l??!",
            style: { fontSize: 16 },
          })
        );
    };
    fetchAddess();
  }, [changePlag]);

  const afterCreateAddressCallback = () => {
    setChangePlag(!changePlag);
  };

  const renderCampaign = (props) => {
    return props.harvestInCampaigns.map((harvest) =>
      renderHarvestCampaign({ ...harvest })
    );
  };

  const onChangeAddress = (e) => {
    setSelectedAddress(e.target.value);
  };
  const onChangePaymentMethod = (e) => {
    setPaymentMethod(e.target.value);
  };

  const renderHarvestCampaign = (props) => {
    if (props.checked) {
      return (
        <div key={props.id} className="card-body pt-0 pr-0 pl-0 pb-0">
          <div className="cart-list-product">
            <a className="float-right remove-cart" href="#">
              <i className="mdi mdi-close"></i>
            </a>
            <img className="img-fluid" src={props.image} alt="" />
            <h5>
              <a href="#">{props.productName}</a>
            </h5>
            <h6>
              <strong>S??? l?????ng:</strong> {props.quantity} {props.unit}
            </h6>
            <p className="offer-price mb-0">
              {(props.price * props.quantity).toLocaleString()}{" "}
              <i className="mdi mdi-tag-outline"></i>{" "}
            </p>
          </div>
        </div>
      );
    }
  };

  const renderAddressRadioItem = (props) => {
    return (
      <Radio key={props.id} value={props}>
        <>
          <strong>{props.name}</strong> - <strong>{props.phone}</strong> <br />{" "}
          {props.address1}
        </>
      </Radio>
    );
  };

  const handleCheckout = () => {
    setLoading(true);
    const fetchCartItems = async () => {
      const cartItemsResponse = await cartApi.getAll(user.id);
      const action = setCart(cartItemsResponse);
      dispatch(action);
    };
    const checkout = async () => {
      const data = {
        name: selectedAddress.name,
        phone: selectedAddress.phone,
        email: user.email,
        address: selectedAddress.address1,
        customerId: user.id,
        paymentTypeId: paymentMethod,
        campaignId: cart.campaignId,
        farmOrders: order,
      };
      console.log(data);
      const result = await orderApi.post(data).catch((err) => {
        if (err.message === "Network Error") {
          notification.error({
            duration: 3,
            message: "M???t k???t n???i m???ng!",
            style: { fontSize: 16 },
          });
        } else if (err.response.status === 400) {
          notification.error({
            duration: 3,
            message: err.response.data.error.message,
            style: { fontSize: 16 },
          });
        } else {
          notification.error({
            duration: 3,
            message: err.response.data.error.message,
            style: { fontSize: 16 },
          });
        }
        setCurrentStep(1);
      });
      if (result !== undefined) {
        if (paymentMethod === 1) {
          if (result === "Order Successfully!") {
            setCurrentStep(4);
            fetchCartItems();
          }
        }
        if (paymentMethod === 2) {
          window.location.href = result;
        }
      }

      setLoading(false);
    };
    checkout();
  };
  const getShipcost = () => {
    if (selectedAddress === null || selectedAddress === undefined) {
      notification.warning({
        duration: 3,
        message: "Vui l??ng ch???n ?????a ch??? ????? ti???p t???c!",
        style: { fontSize: 16 },
      });
      return;
    }
    const getShipcostFromServer = async () => {
      setLoading(true);
      await orderApi
        .getShipcost({
          cost: cartTotal,
          address: selectedAddress.address1,
          campaignId: cart.campaignId,
        })
        .then((result) => {
          setShipCost(parseInt(result));
          setCurrentStep(2);
        })
        .catch((err) => {
          if (err.message === "Network Error") {
            notification.error({
              duration: 3,
              message: "M???t k???t n???i m???ng!",
              style: { fontSize: 16 },
            });
          } else if (err.response.status === 404) {
            notification.error({
              duration: 3,
              message: "Chi???n d???ch kh??ng h??? tr??? giao h??ng t???i ?????a ch??? n??y!",
              style: { fontSize: 16 },
            });
          } else {
            notification.error({
              duration: 3,
              message: "C?? l???i x???y ra trong qu?? tr??nh x??? l??",
              style: { fontSize: 16 },
            });
          }
        });
      setLoading(false);
    };
    getShipcostFromServer();
  };

  return (
    <>
      {momoLoading ? (
        <LoadingPage />
      ) : (
        <>
          <section className="checkout-page section-padding">
            <div className="container">
              <div className="d-flex justify-content-center">
                {loading ? (
                  <>
                    <Spin indicator={antIcon} /> <br /> <br />{" "}
                  </>
                ) : null}
              </div>
              <div className="row">
                <div className="col-md-8">
                  <div className="checkout-step">
                    <div className="accordion" id="accordionExample">
                      <div className="card checkout-step-one">
                        <div className="card-header" id="headingOne">
                          <h5 className="mb-0">
                            <button
                              className={
                                currentStep === 1
                                  ? "btn btn-link"
                                  : "btn btn-link collapsed"
                              }
                              type="button"
                              aria-expanded="true"
                              aria-controls="collapseOne"
                            >
                              <span className="number">1</span>X??c Nh???n ?????a Ch???
                              Giao H??ng
                            </button>
                          </h5>
                        </div>
                        <div
                          id="collapseOne"
                          className={
                            currentStep === 1 ? "collapse show" : "collapse"
                          }
                          aria-labelledby="headingOne"
                          data-parent="#accordionExample"
                        >
                          <div className="card-body">
                            <div className="row" style={{ marginLeft: 50 }}>
                              <Radio.Group
                                onChange={(e) => {
                                  onChangeAddress(e);
                                }}
                                value={selectedAddress}
                              >
                                <Space direction="vertical">
                                  {addresses &&
                                    addresses.map((address) =>
                                      renderAddressRadioItem(address)
                                    )}
                                </Space>
                              </Radio.Group>
                            </div>
                            <br />
                            <CreateAddressForm
                              countAddress={addresses.length}
                              callback={afterCreateAddressCallback}
                            />
                            <br />

                            <button
                              disabled={loading}
                              type="button"
                              onClick={() => navigate("/cart")}
                              style={{ marginRight: 20 }}
                              className="btn btn-secondary mb-2 btn-lg"
                            >
                              Tr??? v???
                            </button>
                            <button
                              disabled={loading}
                              type="button"
                              aria-expanded="false"
                              aria-controls="collapseTwo"
                              className="btn btn-secondary mb-2 btn-lg"
                              onClick={getShipcost}
                            >
                              Ti???p
                            </button>
                          </div>
                        </div>
                      </div>
                      <div className="card checkout-step-two">
                        <div className="card-header" id="headingTw0">
                          <h5 className="mb-0">
                            <button
                              className={
                                currentStep === 2
                                  ? "btn btn-link"
                                  : "btn btn-link collapsed"
                              }
                              type="button"
                              aria-expanded="true"
                              aria-controls="collapseTwo"
                            >
                              <span className="number">2</span>X??c nh???n th??ng
                              tin ????n h??ng
                            </button>
                          </h5>
                        </div>
                        <div
                          id="collapseTow"
                          className={
                            currentStep === 2 ? "collapse show" : "collapse"
                          }
                          aria-labelledby="headingTow"
                          data-parent="#accordionExample"
                        >
                          <div className="card-body">
                            {selectedAddress && (
                              <div style={{ marginLeft: 30 }}>
                                <h4 className="heading-design-h4">
                                  I. Th??ng tin giao h??ng
                                </h4>
                                <br />
                                <div style={{ marginLeft: 30 }}>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      T??n ng?????i nh???n:{" "}
                                    </strong>{" "}
                                    <span style={{ fontWeight: 400 }}>
                                      {selectedAddress.name}
                                    </span>
                                  </h5>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      S??? ??i???n tho???i:{" "}
                                    </strong>{" "}
                                    <span style={{ fontWeight: 400 }}>
                                      {selectedAddress.phone}
                                    </span>
                                  </h5>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">?????a ch???: </strong>{" "}
                                    <span style={{ fontWeight: 400 }}>
                                      {selectedAddress.address1}
                                    </span>
                                  </h5>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      Giao h??ng d??? ki???n:{" "}
                                    </strong>{" "}
                                    <span style={{ fontWeight: 400 }}>
                                      {cart &&
                                        parseTimeDMY(cart.expectedDeliveryTime)}
                                    </span>
                                  </h5>
                                  <br />
                                </div>
                                <h4 className="heading-design-h4">
                                  II. Th??ng tin ????n h??ng
                                </h4>
                                <br />
                                <div style={{ marginLeft: 30 }}>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      S??? l?????ng h??ng:{" "}
                                    </strong>{" "}
                                    <span style={{ fontWeight: 400 }}>
                                      {orderCount} s???n ph???m
                                    </span>
                                  </h5>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      Ti???n h??ng:{" "}
                                    </strong>{" "}
                                    <span style={{ fontWeight: 400 }}>
                                      {cartTotal.toLocaleString() + " VN??"}
                                    </span>
                                  </h5>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      Ph?? ship:{" "}
                                    </strong>
                                    <span style={{ fontWeight: 400 }}>
                                      {shipCost.toLocaleString() + " VN??"}
                                    </span>
                                  </h5>
                                  <h5 className="heading-design-h5">
                                    <strong className="title">
                                      C???n thanh to??n:{" "}
                                    </strong>
                                    <span style={{ fontWeight: 400 }}>
                                      {(shipCost + cartTotal).toLocaleString() +
                                        " VN??"}{" "}
                                    </span>
                                  </h5>
                                  <br />
                                </div>
                              </div>
                            )}

                            <button
                              type="button"
                              onClick={() => {
                                setCurrentStep(1);
                              }}
                              style={{ marginRight: 20 }}
                              className="btn btn-secondary mb-2 btn-lg"
                            >
                              Tr??? v???
                            </button>
                            <button
                              type="button"
                              aria-expanded="false"
                              aria-controls="collapseTwo"
                              className="btn btn-secondary mb-2 btn-lg"
                              onClick={() => setCurrentStep(3)}
                            >
                              Ti???p
                            </button>
                          </div>
                        </div>
                      </div>
                      <div className="card checkout-step-three">
                        <div className="card-header" id="headingthree">
                          <h5 className="mb-0">
                            <button
                              className={
                                currentStep === 3
                                  ? "btn btn-link"
                                  : "btn btn-link collapsed"
                              }
                              type="button"
                              aria-expanded="true"
                              aria-controls="collapseOne"
                            >
                              <span className="number">3</span>X??c Nh???n H??nh
                              Th???c Thanh To??n
                            </button>
                          </h5>
                        </div>
                        <div
                          id="collapseThree"
                          className={
                            currentStep === 3 ? "collapse show" : "collapse"
                          }
                          aria-labelledby="headingThree"
                          data-parent="#accordionExample"
                        >
                          <div className="card-body">
                            <div className="row" style={{ marginLeft: 50 }}>
                              <Radio.Group
                                onChange={(e) => {
                                  onChangePaymentMethod(e);
                                }}
                                value={paymentMethod}
                              >
                                <Space direction="vertical">
                                  <Radio key={1} value={1}>
                                    <>
                                      <h5>
                                        <strong>
                                          Thanh to??n khi nh???n h??ng (COD)
                                        </strong>
                                      </h5>
                                    </>
                                  </Radio>
                                  {isMobile ? null : (
                                    <Radio key={2} value={2}>
                                      <>
                                        <h5>
                                          <strong>Thanh to??n qua v?? </strong>
                                          <img
                                            style={{ height: 40, width: 40 }}
                                            src="/img/MoMo_Logo.png"
                                          ></img>
                                        </h5>
                                      </>
                                    </Radio>
                                  )}
                                </Space>
                              </Radio.Group>
                            </div>
                            <br />

                            <button
                              disabled={loading}
                              type="button"
                              onClick={() => setCurrentStep(2)}
                              style={{ marginRight: 20 }}
                              className="btn btn-secondary mb-2 btn-lg"
                            >
                              Tr??? v???
                            </button>
                            <button
                              disabled={loading}
                              type="button"
                              aria-expanded="false"
                              aria-controls="collapseTwo"
                              className="btn btn-secondary mb-2 btn-lg"
                              onClick={handleCheckout}
                            >
                              Thanh to??n
                            </button>
                          </div>
                        </div>
                      </div>

                      <div className="card">
                        <div className="card-header" id="headingThree">
                          <h5 className="mb-0">
                            <button
                              className={
                                currentStep === 4
                                  ? "btn btn-link"
                                  : "btn btn-link collapsed"
                              }
                              type="button"
                              aria-expanded="false"
                              aria-controls="collapseThree"
                            >
                              <span className="number">4</span> Ho??n T???t ?????t
                              H??ng
                            </button>
                          </h5>
                        </div>

                        <div
                          id="collapseThree"
                          className={
                            currentStep === 4 ? "collapse show" : "collapse"
                          }
                          aria-labelledby="headingThree"
                          data-parent="#accordionExample"
                        >
                          <div className="card-body">
                            <div className="text-center">
                              <div className="col-lg-10 col-md-10 mx-auto order-done">
                                <i className="mdi mdi-check-circle-outline text-secondary"></i>

                                <h4 className="text-success">
                                  Ch??c m???ng! ????n h??ng c???a b???n ???? ???????c ?????t th??nh
                                  c??ng.
                                </h4>
                              </div>
                              <div className="text-center">
                                <Link to="/">
                                  <button
                                    type="submit"
                                    className="btn btn-secondary mb-2 btn-lg"
                                  >
                                    V??? Trang ch???
                                  </button>
                                </Link>
                              </div>{" "}
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                  </div>
                </div>

                <div className="col-md-4">
                  <div className="card">
                    <h5 className="card-header">
                      Gi??? H??ng
                      <span className="text-secondary float-right">
                        {orderCount} s???n ph???m
                      </span>
                    </h5>

                    {cart &&
                      cart.farms.map((farm) => renderCampaign({ ...farm }))}
                  </div>
                </div>
              </div>
            </div>
          </section>
        </>
      )}
    </>
  );
};

export default CheckoutSection;
