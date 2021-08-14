---
layout: post
title: Mint Export to YNAB Import
date: 2021-08-11 06:11:00-8000
author: me
category: dailies
tags: [mint, ynab, python, csv]
keywords: [mint, ynab, python, csv]
---

Are you looking to switch from [Mint](https://mint.intuit.com/) to [YNAB](https://www.youneedabudget.com/) and want to import some existing data?

Here's a quick script to translate a Mint CSV export to a YNAB CSV import.

```python
"""
    Convert mint.com transaction exports (CSV) into YNAB.com (you need a budget) CSV imports.

     Mint.com transactions have the following fields:
     * Date
     * Description
     * Original Description
     * Amount
     * Transaction Type
     * Category
     * Account Name
     * Labels
     * Notes

     YNAB.com file imports expect the following fields:
     * Date
     * Payee
     * Memo
     * Amount
"""
import csv
import sys
import typing

# This script translates the following fields:
#
# * Date => Date
# * Payee => Description
# * Memo => Original Description
# * Amount => Amount (Negative/Positive depending on transaction type)
MINT_FIELDS = ('Date', 'Description', 'Original Description', 'Amount')
YNAB_FIELDS = ('Date', 'Payee', 'Memo', 'Amount', 'Category')


def remap(fields: typing.Dict[str, str]) -> typing.Dict[str, typing.Any]:
    """
    Given a mapping of fields, remap them to a new mapping based on our
    known rules.
    :param fields: Fields from mint.com transaction to remap to YNAB.
    """
    amount = float(fields['Amount'])
    if fields['Transaction Type'] == 'debit':
        amount *= -1

    return {
        'Date': fields['Date'],
        'Payee': fields.get('Description', ''),
        'Memo': fields.get('Original Description', ''),
        'Amount': amount
    }


def main(mint_path: str, ynab_path: str) -> None:
    """
    Convert mint.com transactions to YNAB import format.

    :param mint_path: Path to mint.com transactions csv
    :param ynab_path: Path to save YNAB file import csv
    """
    with open(mint_path, 'r', encoding='utf-8') as mint:
        with open(ynab_path, 'w', encoding='utf-8') as ynab:
            reader = csv.DictReader(mint)

            writer = csv.DictWriter(ynab, YNAB_FIELDS)
            writer.writeheader()

            for line in reader:
                writer.writerow(remap(line))


if __name__ == '__main__':
    main(*sys.argv[1:])
```

Simply use like:

```sh
python mint-to-ynab.py mint-transactions.csv ynab-transactions.csv
```

Unfortunately, YNAB CSV imports don't support Category/Category Group values tickets [here](https://support.youneedabudget.com/t/x1bw4k/how-to-import-categories-from-csv) and [here](https://support.youneedabudget.com/t/p8h8bzg/csv-import-with-budget-categories). I don't understand this and it sucks but such is life.
