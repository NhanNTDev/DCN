import axios from "axios";

export const getProduct = async () => {
  let result;
  await axios({
    method: "GET",
    url: "http://localhost:3000/product",
    data: null,
  })
    .then((res) => {
      console.log(res);
      result = res.data;
    })
    .catch((err) => {
      console.log(err);
    });
  return result;
};