%%raw(`import './App.css';`)

type addTransaction = {
  typeOfTransaction: string,
  amtOfTransaction: string,
}

type state = {
  transactionList: array<addTransaction>,
  typeOfTransaction: string,
  amtOfTransaction: string,
}

type action =
  AddTransaction | TypeOfTransactionInputChanged(string) | AmtOfTransactionInputChanged(string)

let initialState = {
  transactionList: [],
  typeOfTransaction: "",
  amtOfTransaction: "",
}

let reducer = (state, action) => {
  switch action {
  | AddTransaction => {
      transactionList: state.transactionList->Js.Array2.concat([
        {
          typeOfTransaction: state.typeOfTransaction,
          amtOfTransaction: state.amtOfTransaction,
        },
      ]),
      typeOfTransaction: "",
      amtOfTransaction: "",
    }
  | TypeOfTransactionInputChanged(newValue) => {
      ...state,
      typeOfTransaction: newValue,
    }
  | AmtOfTransactionInputChanged(newValue) => {
      ...state,
      amtOfTransaction: newValue,
    }
  }
}

@react.component
let make = () => {
  let (state, dispatch) = React.useReducer(reducer, initialState)
  let (income, setIncome) = React.useState(_ => 0)
  let (expense, setExpense) = React.useState(_ => 0)

  let handleTypeOfTransaction = e => {
    let newValue = ReactEvent.Form.target(e)["value"]
    newValue->TypeOfTransactionInputChanged->dispatch
  }

  let handleAmtOfTransaction = e => {
    let str = ReactEvent.Form.target(e)["value"]
    Js.String2.replaceByRe(str, %re("/^[ A-Za-z_@./#&*]*$/"), "")
    ->AmtOfTransactionInputChanged
    ->dispatch
  }

  let handleTransactionSubmit = e => {
    dispatch(AddTransaction)
    Js.String.slice(~from=0, ~to_=1, state.amtOfTransaction) == "-"
      ? setExpense(_prev =>
          _prev +
          switch Belt.Int.fromString(state.amtOfTransaction) {
          | None => -1
          | Some(v) => v
          }
        )
      : setIncome(_prev =>
          _prev +
          switch Belt.Int.fromString(state.amtOfTransaction) {
          | None => -1
          | Some(v) => v
          }
        )
  }

  let list = Belt.Array.map(state.transactionList, transaction => {
    <div className="listOfTransaction" key={transaction.typeOfTransaction}>
      <h3> {React.string(transaction.typeOfTransaction)} </h3>
      <h3> {React.string(transaction.amtOfTransaction)} </h3>
    </div>
  })

  React.useEffect1(() => {
    Js.log(expense)
    None
  }, [expense])

  <div className="App">
    <h1> {React.string("Expense Tracker")} </h1>
    <div className="heading">
      <h2> {React.string("Your Balance: " ++ Belt.Int.toString(income - expense))} </h2>
      <h2> {React.string("Income: " ++ Belt.Int.toString(income))} </h2>
      <h2> {React.string("Expense: " ++ Belt.Int.toString(expense))} </h2>
    </div>
    <div> {React.array(list)} </div>
    <div className="form">
      <div className="transactionForm">
        <label> {React.string("Text")} </label>
        <input
          name="typeOfTransaction"
          value={state.typeOfTransaction}
          type_="text"
          onChange={handleTypeOfTransaction}
        />
      </div>
      <div className="transactionForm">
        <label> {React.string("Amount (negative - expense, positive - income)")} </label>
        <input
          name="amtOfTransaction"
          value={state.amtOfTransaction}
          type_="text"
          onChange={handleAmtOfTransaction}
        />
      </div>
    </div>
    <button onClick={handleTransactionSubmit}> {"Add Transaction"->React.string} </button>
  </div>
}
