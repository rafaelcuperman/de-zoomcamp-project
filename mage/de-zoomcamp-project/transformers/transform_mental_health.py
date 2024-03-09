if 'transformer' not in globals():
    from mage_ai.data_preparation.decorators import transformer
if 'test' not in globals():
    from mage_ai.data_preparation.decorators import test


@transformer
def transform(data, *args, **kwargs):
    # Remove records without date
    data = data[~data['Timestamp'].isnull()]

    # Remove records without country
    data = data[~data['Country'].isnull()]

    # Convert column names to snake case
    reg = '(?<=[a-z])(?=[A-Z])'

    data.columns = (data.columns
                .str.replace(' ', '_')
                .str.replace('-', '_')
                .str.replace(reg, '_', regex=True)
                .str.lower()
             )

    # Remove duplicated rows
    before = len(data)

    data = data[~data.duplicated()]
    print(f'Number of elminated duplicated rows: {before-len(data)}')
    print(data.dtypes)
    return data


@test
def test_output(output, *args) -> None:
    """
    Template code for testing the output of the block.
    """
    assert output is not None, 'The output is undefined'
    
    assert len(output[output['country'].isnull()]) == 0, 'Null values in country found'

    assert len(output[output['timestamp'].isnull()]) == 0, 'Null values in timestamp found'

