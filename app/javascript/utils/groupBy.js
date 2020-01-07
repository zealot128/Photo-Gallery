export default function (array, funcProp) {
  return array.reduce((acc, val) =>  {
    (acc[funcProp(val)] = acc[funcProp(val)] || []).push(val);
    return acc;
  }, {})
}
