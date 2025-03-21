import x.json2 as json
import time

const fixed_time = time.Time{
	year: 2022
	month: 3
	day: 11
	hour: 13
	minute: 54
	second: 25
	unix: 1647006865
}

type StringAlias = string
type BoolAlias = bool
type IntAlias = int
type TimeAlias = time.Time
type StructAlias = StructType[int]
type EnumAlias = Enumerates

type SumTypes = StructType[string] | bool | int | string | time.Time

enum Enumerates {
	a
	b
	c
	d
	e = 99
	f
}

struct StructType[T] {
mut:
	val T
}

struct StructTypeOption[T] {
mut:
	val ?T
}

struct StructTypePointer[T] {
mut:
	val &T
}

fn test_types() {
	assert json.encode(StructType[string]{}) == '{"val":""}'
	assert json.encode(StructType[string]{ val: '' }) == '{"val":""}'
	assert json.encode(StructType[string]{ val: 'a' }) == '{"val":"a"}'

	assert json.encode(StructType[bool]{}) == '{"val":false}'
	assert json.encode(StructType[bool]{ val: false }) == '{"val":false}'
	assert json.encode(StructType[bool]{ val: true }) == '{"val":true}'

	assert json.encode(StructType[int]{}) == '{"val":0}'
	assert json.encode(StructType[int]{ val: 0 }) == '{"val":0}'
	assert json.encode(StructType[int]{ val: 1 }) == '{"val":1}'

	assert json.encode(StructType[time.Time]{}) == '{"val":"0000-00-00T00:00:00.000Z"}'
	assert json.encode(StructType[time.Time]{ val: fixed_time }) == '{"val":"2022-03-11T13:54:25.000Z"}'

	assert json.encode(StructType[StructType[int]]{
		val: StructType[int]{
			val: 1
		}
	}) == '{"val":{"val":1}}'

	assert json.encode(StructType[Enumerates]{}) == '{"val":0}'
	assert json.encode(StructType[Enumerates]{ val: Enumerates.a }) == '{"val":0}'
	assert json.encode(StructType[Enumerates]{ val: Enumerates.d }) == '{"val":3}'
	assert json.encode(StructType[Enumerates]{ val: Enumerates.e }) == '{"val":99}'
	assert json.encode(StructType[Enumerates]{ val: Enumerates.f }) == '{"val":100}'
}

fn test_option_types() {
	assert json.encode(StructTypeOption[string]{ val: none }) == '{}'
	assert json.encode(StructTypeOption[string]{}) == '{}'
	assert json.encode(StructTypeOption[string]{ val: '' }) == '{"val":""}'
	assert json.encode(StructTypeOption[string]{ val: 'a' }) == '{"val":"a"}'

	assert json.encode(StructTypeOption[bool]{ val: none }) == '{}'
	assert json.encode(StructTypeOption[bool]{}) == '{}'
	assert json.encode(StructTypeOption[bool]{ val: false }) == '{"val":false}'
	assert json.encode(StructTypeOption[bool]{ val: true }) == '{"val":true}'

	assert json.encode(StructTypeOption[int]{ val: none }) == '{}'
	assert json.encode(StructTypeOption[int]{}) == '{}'
	assert json.encode(StructTypeOption[int]{ val: 0 }) == '{"val":0}'
	assert json.encode(StructTypeOption[int]{ val: 1 }) == '{"val":1}'

	assert json.encode(StructTypeOption[time.Time]{}) == '{}'
	assert json.encode(StructTypeOption[time.Time]{ val: time.Time{} }) == '{"val":"0000-00-00T00:00:00.000Z"}'
	assert json.encode(StructTypeOption[time.Time]{ val: fixed_time }) == '{"val":"2022-03-11T13:54:25.000Z"}'

	assert json.encode(StructTypeOption[StructType[int]]{
		val: StructType[int]{
			val: 1
		}
	}) == '{"val":{"val":1}}'

	assert json.encode(StructTypeOption[Enumerates]{}) == '{}'
}

fn test_array() {
	assert json.encode(StructType[[]string]{}) == '{"val":[]}'
	assert json.encode(StructType[[]string]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]string]{ val: ['0'] }) == '{"val":["0"]}'
	assert json.encode(StructType[[]string]{ val: ['1'] }) == '{"val":["1"]}'

	assert json.encode(StructType[[]int]{}) == '{"val":[]}'
	assert json.encode(StructType[[]int]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]int]{ val: [0] }) == '{"val":[0]}'
	assert json.encode(StructType[[]int]{ val: [1] }) == '{"val":[1]}'
	assert json.encode(StructType[[]int]{ val: [0, 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructType[[]byte]{}) == '{"val":[]}'
	assert json.encode(StructType[[]byte]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]byte]{ val: [byte(0)] }) == '{"val":[0]}'
	assert json.encode(StructType[[]byte]{ val: [byte(1)] }) == '{"val":[1]}'
	assert json.encode(StructType[[]byte]{ val: [byte(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructType[[]i64]{}) == '{"val":[]}'
	assert json.encode(StructType[[]i64]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]i64]{ val: [i64(0)] }) == '{"val":[0]}'
	assert json.encode(StructType[[]i64]{ val: [i64(1)] }) == '{"val":[1]}'
	assert json.encode(StructType[[]i64]{ val: [i64(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructType[[]u64]{}) == '{"val":[]}'
	assert json.encode(StructType[[]u64]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]u64]{ val: [u64(0)] }) == '{"val":[0]}'
	assert json.encode(StructType[[]u64]{ val: [u64(1)] }) == '{"val":[1]}'
	assert json.encode(StructType[[]u64]{ val: [u64(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructType[[]f64]{}) == '{"val":[]}'
	assert json.encode(StructType[[]f64]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]f64]{ val: [f64(0)] }) == '{"val":[0.0]}'
	assert json.encode(StructType[[]f64]{ val: [f64(1)] }) == '{"val":[1.0]}'
	assert json.encode(StructType[[]f64]{ val: [f64(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0.0,1.0,0.0,2.0,3.0,2.0,5.0,1.0]}'

	assert json.encode(StructType[[]bool]{}) == '{"val":[]}'
	assert json.encode(StructType[[]bool]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructType[[]bool]{ val: [true] }) == '{"val":[true]}'
	assert json.encode(StructType[[]bool]{ val: [false] }) == '{"val":[false]}'
	assert json.encode(StructType[[]bool]{ val: [false, true, false] }) == '{"val":[false,true,false]}'

	array_of_struct := [StructType[bool]{
		val: true
	}, StructType[bool]{
		val: false
	}]
	assert json.encode(StructType[[]StructType[bool]]{ val: array_of_struct }) == '{"val":[{"val":true},{"val":false}]}'
}

fn test_option_array() {
	assert json.encode(StructTypeOption[[]string]{}) == '{}'
	assert json.encode(StructTypeOption[[]string]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]string]{ val: ['0'] }) == '{"val":["0"]}'
	assert json.encode(StructTypeOption[[]string]{ val: ['1'] }) == '{"val":["1"]}'

	assert json.encode(StructTypeOption[[]int]{}) == '{}'
	assert json.encode(StructTypeOption[[]int]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]int]{ val: [0] }) == '{"val":[0]}'
	assert json.encode(StructTypeOption[[]int]{ val: [1] }) == '{"val":[1]}'
	assert json.encode(StructTypeOption[[]int]{ val: [0, 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructTypeOption[[]byte]{}) == '{}'
	assert json.encode(StructTypeOption[[]byte]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]byte]{ val: [byte(0)] }) == '{"val":[0]}'
	assert json.encode(StructTypeOption[[]byte]{ val: [byte(1)] }) == '{"val":[1]}'
	assert json.encode(StructTypeOption[[]byte]{ val: [byte(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructTypeOption[[]i64]{}) == '{}'
	assert json.encode(StructTypeOption[[]i64]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]i64]{ val: [i64(0)] }) == '{"val":[0]}'
	assert json.encode(StructTypeOption[[]i64]{ val: [i64(1)] }) == '{"val":[1]}'
	assert json.encode(StructTypeOption[[]i64]{ val: [i64(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructTypeOption[[]u64]{}) == '{}'
	assert json.encode(StructTypeOption[[]u64]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]u64]{ val: [u64(0)] }) == '{"val":[0]}'
	assert json.encode(StructTypeOption[[]u64]{ val: [u64(1)] }) == '{"val":[1]}'
	assert json.encode(StructTypeOption[[]u64]{ val: [u64(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0,1,0,2,3,2,5,1]}'

	assert json.encode(StructTypeOption[[]f64]{}) == '{}'
	assert json.encode(StructTypeOption[[]f64]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]f64]{ val: [f64(0)] }) == '{"val":[0.0]}'
	assert json.encode(StructTypeOption[[]f64]{ val: [f64(1)] }) == '{"val":[1.0]}'
	assert json.encode(StructTypeOption[[]f64]{ val: [f64(0), 1, 0, 2, 3, 2, 5, 1] }) == '{"val":[0.0,1.0,0.0,2.0,3.0,2.0,5.0,1.0]}'

	assert json.encode(StructTypeOption[[]bool]{}) == '{}'
	assert json.encode(StructTypeOption[[]bool]{ val: [] }) == '{"val":[]}'
	assert json.encode(StructTypeOption[[]bool]{ val: [true] }) == '{"val":[true]}'
	assert json.encode(StructTypeOption[[]bool]{ val: [false] }) == '{"val":[false]}'
	assert json.encode(StructTypeOption[[]bool]{ val: [false, true, false] }) == '{"val":[false,true,false]}'

	array_of_struct := [StructType[bool]{
		val: true
	}, StructType[bool]{
		val: false
	}]
	assert json.encode(StructTypeOption[[]StructType[bool]]{ val: array_of_struct }) == '{"val":[{"val":true},{"val":false}]}'
}

fn test_alias() {
	assert json.encode(StructType[StringAlias]{}) == '{"val":""}'
	assert json.encode(StructType[StringAlias]{ val: '' }) == '{"val":""}'
	assert json.encode(StructType[StringAlias]{ val: 'a' }) == '{"val":"a"}'

	assert json.encode(StructType[BoolAlias]{}) == '{"val":false}'
	assert json.encode(StructType[BoolAlias]{ val: false }) == '{"val":false}'
	assert json.encode(StructType[BoolAlias]{ val: true }) == '{"val":true}'

	assert json.encode(StructType[IntAlias]{}) == '{"val":0}'
	assert json.encode(StructType[IntAlias]{ val: 0 }) == '{"val":0}'
	assert json.encode(StructType[IntAlias]{ val: 1 }) == '{"val":1}'

	assert json.encode(StructType[TimeAlias]{}) == '{"val":"0000-00-00T00:00:00.000Z"}'
	assert json.encode(StructType[TimeAlias]{ val: fixed_time }) == '{"val":"2022-03-11T13:54:25.000Z"}'

	assert json.encode(StructType[StructAlias]{}) == '{"val":{"val":0}}'
	assert json.encode(StructType[StructAlias]{ val: StructType[int]{0} }) == '{"val":{"val":0}}'
	assert json.encode(StructType[StructAlias]{ val: StructType[int]{1} }) == '{"val":{"val":1}}'
}

fn test_sumtypes() {
	assert json.encode(StructType[SumTypes]{}) == '{}'
	assert json.encode(StructType[SumTypes]{ val: '' }) == '{"val":""}'
	assert json.encode(StructType[SumTypes]{ val: 'a' }) == '{"val":"a"}'

	assert json.encode(StructType[SumTypes]{ val: false }) == '{"val":false}'
	assert json.encode(StructType[SumTypes]{ val: true }) == '{"val":true}'

	assert json.encode(StructType[SumTypes]{ val: 0 }) == '{"val":0}'
	assert json.encode(StructType[SumTypes]{ val: 1 }) == '{"val":1}'

	assert json.encode(StructType[SumTypes]{ val: fixed_time }) == '{"val":2022-03-11T13:54:25.000Z}'

	assert json.encode(StructType[StructType[SumTypes]]{
		val: StructType[SumTypes]{
			val: 1
		}
	}) == '{"val":{"val":1}}'

	// assert json.encode(StructType[SumTypes]{ val: StructType[string]{
	// 		val: '111111'
	// 	} }) == '{"val":1}'

	assert json.encode(StructType[StructType[SumTypes]]{
		val: StructType[SumTypes]{
			val: 1
		}
	}) == '{"val":{"val":1}}'
}

fn test_maps() {
	assert json.encode(StructType[map[string]map[string]int]{}) == '{"val":{}}'
	assert json.encode(StructType[map[string]string]{
		val: {
			'1': '1'
		}
	}) == '{"val":{"1":"1"}}'
	assert json.encode(StructType[map[string]int]{
		val: {
			'1': 1
		}
	}) == '{"val":{"1":1}}'
	// assert json.encode(StructType[map[string]map[string]int]{
	// 	val: {
	// 		'a': {
	// 			'1': 1
	// 		}
	// 	}
	// }) == '{"val":{"a":{"1":1}}}'
}
