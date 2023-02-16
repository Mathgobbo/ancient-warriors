import { createContext, Dispatch, ReactNode, SetStateAction, useContext, useState } from "react";

// https://docs.onflow.org/fcl/reference/api/#transaction-statuses
/**
 * STATUS CODE  DESCRIPTION <br/>
 * -1 No Active Transaction<br/>
 * 0  Unknown<br/>
 * 1  Transaction Pending - Awaiting Finalization<br/>
 * 2  Transaction Finalized - Awaiting Execution<br/>
 * 3  Transaction Executed - Awaiting Sealing<br/>
 * 4  Transaction Sealed - Transaction Complete. At this point the transaction result has been committed to the blockchain.<br/>
 * 5  Transaction Expired<br/>
 */

interface ITransactionContext {
  initTransactionState: () => void;
  transactionInProgress: boolean;
  transactionStatus: number;
  txId: string;
  setTxId: Dispatch<SetStateAction<string>>;
  setTransactionStatus: Dispatch<SetStateAction<number>>;
}

export const TransactionContext = createContext<ITransactionContext>({} as ITransactionContext);

export const useTransaction = () => useContext(TransactionContext);

export default function TransactionProvider({ children }: { children: ReactNode }) {
  const [transactionInProgress, setTransactionInProgress] = useState(false);
  const [transactionStatus, setTransactionStatus] = useState(-1);
  const [txId, setTxId] = useState("");

  function initTransactionState() {
    setTransactionInProgress(true);
    setTransactionStatus(-1);
  }

  const value: ITransactionContext = {
    transactionInProgress,
    transactionStatus,
    txId,
    initTransactionState,
    setTxId,
    setTransactionStatus,
  };

  console.log("TransactionProvider", value);

  return <TransactionContext.Provider value={value}>{children}</TransactionContext.Provider>;
}
